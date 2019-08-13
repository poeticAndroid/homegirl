module program;

import std.stdio;
import std.string;
import std.path;
import std.array;
import std.file;
import std.algorithm;
import std.conv;
import riverd.lua;
import riverd.lua.types;

import machine;
import screen;
import viewport;
import lua_api._basic_;
import pixmap;
import image_loader;
import sample;

/**
  a program that the machine can run
*/
class Program
{
  bool running = true; /// is the program running?
  int exitcode = 0; /// exit code
  string filename; /// filename of the Lua script currently running
  string[] args; /// program arguments
  string cwd; /// current working directory
  string[3] io; /// input/output/error buffers
  Machine machine; /// the machine that this program runs on
  lua_State* lua; /// Lua state
  double stepInterval = -1; /// minimum milliseconds between steps. -1 = step only on input
  double nextStep = 0; /// timestamp for next step

  Program[] children; /// child processes

  Viewport[] viewports; /// the viewports accessible by this program
  Viewport activeViewport; /// viewport currently active for graphics operations

  Pixmap[] pixmaps; /// pixmap images created or loaded by this program
  Pixmap[][] fonts; /// fonts loaded by this program

  Sample[] samples; /// samples created or loaded by this program

  /** 
    Initiate a new program!
  */
  this(Machine machine, string filename, string[] args = [], string cwd = null)
  {
    this.machine = machine;
    this.filename = filename;
    this.args = args;
    this.cwd = cwd;
    if (!this.cwd)
      this.cwd = this.machine.dirName(this.filename);
    this.children ~= null;
    this.viewports ~= null;
    this.pixmaps ~= null;
    this.fonts ~= null;
    this.samples ~= null;

    // Load the Lua library.
    dylib_load_lua();
    this.lua = luaL_newstate();
    luaL_openlibs(this.lua);
    registerFunctions(this);
    string luacode = readText(this.actualFile(this.filename));
    if (luaL_loadbuffer(this.lua, toStringz(luacode), luacode.length, toStringz(this.filename)))
      this.croak();
  }

  /**
    advance the program one step
  */
  void step(uint timestamp)
  {
    if (this.nextStep == 0 && this.running && lua_pcall(this.lua, 0, LUA_MULTRET, 0))
      this.croak();
    if (this.nextStep == 0 && this.running)
      this.call("_init");
    if (this.nextStep == 0)
      this.nextStep = timestamp;
    if (this.running)
      this.call("_step", timestamp);
    this.nextStep += this.stepInterval;
    if (this.nextStep < timestamp)
      this.nextStep = timestamp;
    if (this.activeViewport)
      this.activeViewport.setHotkey(0);
  }

  /**
    end the program properly
  */
  void shutdown(int code)
  {
    if (this.running)
    {
      this.running = false;
      this.exitcode = code;
      this.call("_shutdown");
    }
    else if (this.lua)
    {
      lua_close(this.lua);
      this.lua = null;
      auto i = this.children.length;
      while (i)
        this.removeChild(cast(uint)--i);
      i = this.viewports.length;
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
    resolve relative path to console path
  */
  string resolve(string path)
  {
    string drive = this.machine.getDrive(path);
    if (drive)
      path = buildNormalizedPath(path[drive.length .. $]);
    else
    {
      drive = this.machine.getDrive(this.cwd);
      path = buildNormalizedPath(this.cwd[drive.length .. $], path);
    }
    path = replace(path, "\\", "/");
    auto segs = split(path, "/");
    path = "";
    for (uint i = 0; i < segs.length; i++)
    {
      switch (segs[i])
      {
      case "":
      case "/":
      case ".":
      case "..":
        break;
      default:
        if (path.length > 0)
          path ~= "/";
        path ~= segs[i];
      }
    }
    return drive ~ path;
  }

  /**
    resolve relative path to host path
  */
  string actualFile(string path)
  {
    string str = this.machine.actualPath(this.resolve(path));
    return str;
  }

  /**
    write to io buffer
  */
  void write(uint buf, string data)
  {
    if (!this.io[buf])
      this.io[buf] = "";
    this.io[buf] ~= data;
  }

  /**
    read from io buffer
  */
  string read(uint buf)
  {
    string data = this.io[buf];
    this.io[buf] = "";
    return data;
  }

  /**
    add child program
  */
  uint addChild(Program prog)
  {
    this.children ~= prog;
    return cast(uint) this.children.length - 1;
  }

  /**
    start child program
  */
  uint startChild(string filename, string[] args = [])
  {
    return this.addChild(this.machine.startProgram(filename, args, this.cwd));
  }

  /**
    remove a child program
  */
  void removeChild(uint pid)
  {
    if (this.children[pid])
    {
      this.children[pid].shutdown(-1);
      this.children[pid] = null;
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
  uint[] loadAnimation(string filename, uint maxframes = -1)
  {
    Pixmap[] frames = image_loader.loadAnimation(filename, maxframes);
    uint[] anim;
    foreach (frame; frames)
    {
      anim ~= this.addPixmap(frame);
    }
    return anim;
  }

  /**
    save animation to file
  */
  void saveAnimation(string filename, uint[] anim)
  {
    Pixmap[] frames;
    foreach (ani; anim)
    {
      if (ani >= this.pixmaps.length || !this.pixmaps[ani])
        throw new Exception("Invalid image!");
      frames ~= this.pixmaps[ani];
    }
    image_loader.saveAnimation(filename, frames);
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
    return this.addFont(this.machine.getFont(filename));
  }

  /**
    remove a pixmap
  */
  void removeFont(uint pmid)
  {
    this.fonts[pmid] = null;
  }

  // === _privates === //

  private void call(string funcname, uint timestamp = 0)
  {
    lua_getglobal(this.lua, toStringz(funcname));
    uint args = 0;
    switch (funcname)
    {
    case "_init":
      lua_createtable(this.lua, cast(uint) this.args.length, 0);
      for (uint i = 0; i < this.args.length; i++)
      {
        lua_pushstring(this.lua, toStringz(this.args[i]));
        lua_rawseti(this.lua, -2, i + 1);
      }
      args++;
      break;
    case "_step":
      lua_pushinteger(this.lua, cast(long) timestamp);
      args++;
      break;
    case "_shutdown":
      lua_pushinteger(this.lua, cast(long) this.exitcode);
      args++;
      break;
    default:
    }
    if (lua_pcall(this.lua, args, 0, 0))
      this.croak();
  }

  private void croak()
  {
    auto err = to!string(lua_tostring(this.lua, -1));
    this.write(2, ("Lua err: " ~ err ~ "\n"));
    writeln("Lua err: " ~ err);
    this.running = false;
  }
}
