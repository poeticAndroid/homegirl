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
    string luacode = "function _init() end\nfunction _step() end\nfunction _shutdown() end\n" ~ readText(
        filename);
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
    }
    this.running = false;
    lua_close(this.lua);
    auto i = this.viewports.length;
    while (i)
      this.removeViewport(cast(uint)--i);
  }

  /**
    create a new screen
  */
  uint createScreen(ubyte mode, ubyte colorBits)
  {
    Screen screen = this.machine.createScreen(mode, colorBits);
    this.viewports ~= screen;
    this.activeViewport = screen;
    return cast(uint) this.viewports.length - 1;
  }

  /**
    create a new viewport
  */
  uint createViewport(uint parentId, int left, int top, uint width, uint height)
  {
    Viewport parent;
    if (parentId == 0)
      parent = this.machine.screens[0];
    else
      parent = this.viewports[parentId];
    Viewport vp = parent.createViewport(left, top, width, height);
    this.viewports ~= vp;
    this.activeViewport = vp;
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
    create pixmap
  */
  uint createPixmap(uint width, uint height, ubyte colorBits)
  {
    this.pixmaps ~= new Pixmap(width, height, colorBits);
    return cast(uint) this.pixmaps.length - 1;
  }

  /**
    create pixmap
  */
  uint loadPixmap(string filename)
  {
    this.pixmaps ~= loadImage(filename);
    return cast(uint) this.pixmaps.length - 1;
  }

  /**
    remove a viewport
  */
  void removePixmap(uint pmid)
  {
    if (this.pixmaps[pmid])
    {
      this.pixmaps[pmid].destroyTexture();
      this.pixmaps[pmid] = null;
    }
  }

  // === _privates === //
}
