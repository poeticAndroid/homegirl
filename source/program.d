module program;

import std.stdio;
import std.string;
import std.file;
import riverd.lua;
import riverd.lua.types;

import machine;
import screen;
import viewport;
import lua_api;
import pixmap;
import image_loader;
import sample;

/**
  a program that the machine can run
*/
class Program
{
  bool running = true; /// is the program running?
  Machine machine; /// the machine that this program runs on
  lua_State* lua; /// Lua state

  Viewport[] viewports; /// the viewports accessible by this program
  Viewport activeViewport; /// viewport currently active for graphics operations

  Pixmap[] pixmaps; /// pixmap images created or loaded by this program
  Pixmap[][] fonts; /// fonts loaded by this program

  Sample[] samples; /// samples created or loaded by this program

  /** 
    Initiate a new program!
  */
  this(Machine machine, string filename)
  {
    this.machine = machine;
    this.viewports ~= null;

    // Load the Lua library.
    dylib_load_lua();
    this.lua = luaL_newstate();
    luaL_openlibs(this.lua);
    registerFunctions(this);
    string luacode = q"{
      function _init()
      end
      function _step()
        exit(0)
      end
      function _shutdown()
      end
    }" ~ readText(filename);
    if (luaL_dostring(this.lua, toStringz(luacode)))
    {
      auto err = lua_tostring(this.lua, -1);
      writeln("Lua err: " ~ fromStringz(err));
      this.running = false;
    }
    if (this.running)
    {
      lua_getglobal(this.lua, "_init");
      if (lua_pcall(this.lua, 0, 0, 0))
      {
        auto err = lua_tostring(this.lua, -1);
        writeln("Lua error: " ~ fromStringz(err));
        this.running = false;
      }
    }
  }

  /**
    advance the program one step
  */
  void step(uint timestamp)
  {
    lua_getglobal(this.lua, "_step");
    lua_pushinteger(this.lua, cast(long) timestamp);
    if (lua_pcall(this.lua, 1, 0, 0))
    {
      auto err = lua_tostring(this.lua, -1);
      writeln("Lua error: " ~ fromStringz(err));
      this.running = false;
    }
  }

  /**
    end the program properly
  */
  void shutdown()
  {
    if (this.running)
    {
      lua_getglobal(this.lua, "_shutdown");
      if (lua_pcall(this.lua, 0, 0, 0))
      {
        auto err = lua_tostring(this.lua, -1);
        writeln("Lua error: " ~ fromStringz(err));
      }
      this.running = false;
    }
    else
    {
      lua_close(this.lua);
      auto i = this.viewports.length;
      while (i)
        this.removeViewport(cast(uint)--i);
      i = this.pixmaps.length;
      while (i)
        this.removePixmap(cast(uint)--i);
      i = this.fonts.length;
      while (i)
        this.removeFont(cast(uint)--i);
      i = this.samples.length;
      while (i)
        this.removeSample(cast(uint)--i);
    }
  }

  /**
    create a new screen
  */
  uint createScreen(ubyte mode, ubyte colorBits)
  {
    Screen screen = this.machine.createScreen(mode, colorBits);
    screen.program = this;
    this.viewports ~= screen;
    this.activeViewport = screen;
    this.machine.focusViewport(screen);
    return cast(uint) this.viewports.length - 1;
  }

  /**
    create a new viewport
  */
  uint createViewport(uint parentId, int left, int top, uint width, uint height)
  {
    Viewport parent;
    if (parentId == 0)
      parent = this.machine.mainScreen;
    else
      parent = this.viewports[parentId];
    Viewport vp = parent.createViewport(left, top, width, height);
    vp.program = this;
    this.viewports ~= vp;
    this.activeViewport = vp;
    this.machine.focusViewport(vp);
    return cast(uint) this.viewports.length - 1;
  }

  /**
    remove a viewport
  */
  void removeViewport(uint vpid)
  {
    Viewport vp = this.viewports[vpid];
    if (!vp)
      return;
    if (this.activeViewport == vp)
      this.activeViewport = null;
    if (vp.getParent())
    {
      vp.getParent().removeViewport(vp);
    }
    else
    {
      this.machine.removeScreen(vp);
    }
    this.viewports[vpid] = null;
    auto i = this.viewports.length;
    while (i > 0)
    {
      i--;
      if (this.viewports[i] && this.viewports[i].containsViewport(vp))
        this.removeViewport(cast(uint) i);
    }
  }

  /**
    add pixmap
  */
  uint addPixmap(Pixmap pixmap)
  {
    this.pixmaps ~= pixmap;
    return cast(uint) this.pixmaps.length - 1;
  }

  /**
    create pixmap
  */
  uint createPixmap(uint width, uint height, ubyte colorBits)
  {
    return this.addPixmap(new Pixmap(width, height, colorBits));
  }

  /**
    load pixmap from file
  */
  uint loadPixmap(string filename)
  {
    return this.addPixmap(loadImage(filename));
  }

  /**
    load animation from file
  */
  uint[] loadAnimation(string filename)
  {
    Pixmap[] frames = image_loader.loadAnimation(filename);
    uint[] anim;
    foreach (frame; frames)
    {
      anim ~= this.addPixmap(frame);
    }
    return anim;
  }

  /**
    remove a pixmap
  */
  void removePixmap(uint pmid)
  {
    if (this.pixmaps[pmid])
    {
      this.pixmaps[pmid].destroyTexture();
      this.pixmaps[pmid] = null;
    }
  }

  /**
    add sample
  */
  uint addSample(Sample sample)
  {
    this.samples ~= sample;
    return cast(uint) this.samples.length - 1;
  }

  /**
    create sample
  */
  uint createSample()
  {
    return this.addSample(new Sample(null));
  }

  /**
    load sample from file
  */
  uint loadSample(string filename)
  {
    return this.addSample(new Sample(filename));
  }

  /**
    remove a sample
  */
  void removeSample(uint pmid)
  {
    if (this.samples[pmid])
    {
      for (uint i = 0; i < this.machine.audio.src.length; i++)
        if (this.machine.audio.src[i] == this.samples[pmid])
          this.machine.audio.src[i] = null;
      this.samples[pmid] = null;
    }
  }

  /**
    add font
  */
  uint addFont(Pixmap[] font)
  {
    this.fonts ~= font;
    return cast(uint) this.fonts.length - 1;
  }

  /**
    load pixmap from file
  */
  uint loadFont(string filename)
  {
    return this.addFont(image_loader.loadAnimation(filename));
  }

  /**
    remove a pixmap
  */
  void removeFont(uint pmid)
  {
    this.fonts[pmid] = null;
  }

  // === _privates === //
}
