module program;

import std.stdio;
import std.string;
import std.file;
import std.random;
import std.algorithm.searching;
import riverd.lua;
import riverd.lua.types;

import machine;
import screen;
import viewport;

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
    this.registerFunctions();
    string luacode = readText(filename);
    if (luaL_dostring(this.lua, toStringz(luacode)))
    {
      auto err = lua_tostring(this.lua, -1);
      writeln("Lua err: " ~ fromStringz(err));
      this.running = false;
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
    this.running = false;
    lua_close(this.lua);
    auto i = this.viewports.length;
    while (i > 0)
      this.removeViewport(cast(uint)--i);
  }

  // === _privates === //

  /**
    create a new screen
  */
  private uint createScreen(ubyte mode, ubyte colorBits)
  {
    Screen screen = this.machine.createScreen(mode, colorBits);
    this.viewports ~= screen;
    this.activeViewport = screen;
    return cast(uint) this.viewports.length - 1;
  }

  /**
    create a new viewport
  */
  private uint createViewport(uint parentId, int left, int top, uint width, uint height)
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
  private void removeViewport(uint vpid)
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

  private void registerFunctions()
  {
    auto lua = this.lua;

    //Setup the userdata
    auto prog = cast(Program*) lua_newuserdata(lua, Program.sizeof);
    *prog = this;
    lua_setglobal(lua, "__program");

    extern (C) int panic(lua_State* L) @trusted
    {
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      prog.shutdown();
      writeln("Shit hit the fan!");
      return 0;
    }

    lua_atpanic(lua, &panic);

    extern (C) int print(lua_State* L) @trusted
    {
      const msg = lua_tostring(L, -1);
      writeln("Program says: " ~ fromStringz(msg));
      return 0;
    }

    lua_register(lua, "print", &print);

    extern (C) int createscreen(lua_State* L) @trusted
    {
      const mode = lua_tointeger(L, -2);
      const colorBits = lua_tointeger(L, -1);
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      lua_pushinteger(L, prog.createScreen(cast(ubyte) mode, cast(ubyte) colorBits));
      return 1;
    }

    lua_register(lua, "createscreen", &createscreen);

    extern (C) int createviewport(lua_State* L) @trusted
    {
      const parentId = lua_tointeger(L, -5);
      const left = lua_tointeger(L, -4);
      const top = lua_tointeger(L, -3);
      const width = lua_tointeger(L, -2);
      const height = lua_tointeger(L, -1);
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      lua_pushinteger(L, prog.createViewport(cast(uint) parentId, cast(int) left,
          cast(int) top, cast(uint) width, cast(uint) height));
      return 1;
    }

    lua_register(lua, "createviewport", &createviewport);

    extern (C) int removeviewport(lua_State* L) @trusted
    {
      const vpId = lua_tointeger(L, -1);
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      prog.removeViewport(cast(uint) vpId);
      return 0;
    }

    lua_register(lua, "removeviewport", &removeviewport);

    extern (C) int setfgcolor(lua_State* L) @trusted
    {
      const cindex = lua_tointeger(L, -1);
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      if (prog.activeViewport)
      {
        prog.activeViewport.pixmap.fgColor = cast(ubyte) cindex;
      }
      else
      {
        lua_pushstring(L, "No active viewport!");
        lua_error(L);
      }
      return 0;
    }

    lua_register(lua, "setfgcolor", &setfgcolor);

    extern (C) int plot(lua_State* L) @trusted
    {
      const x = lua_tointeger(L, -2);
      const y = lua_tointeger(L, -1);
      //Get the pointer
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      if (prog.activeViewport)
      {
        prog.activeViewport.pixmap.plot(cast(uint) x, cast(uint) y);
      }
      else
      {
        lua_pushstring(L, "No active viewport!");
        lua_error(L);
      }

      return 0;
    }

    lua_register(lua, "plot", &plot);
  }

}
