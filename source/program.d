module program;

import std.stdio;
import std.string;
import std.file;
import std.random;
import riverd.lua;
import riverd.lua.types;

import machine;

/**
  a program that the machine can run
*/
class Program
{
  bool running = true; /// is the program running?
  Machine machine; /// the machine that this program runs on
  lua_State* lua; /// Lua state

  /** 
    Initiate a new program!
  */
  this(Machine machine, string filename)
  {
    this.machine = machine;
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
      writeln("Lua err: " ~ fromStringz(err));
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
  }

  // === _privates === //

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

    extern (C) int setfgcolor(lua_State* L) @trusted
    {
      const cindex = lua_tointeger(L, -1);
      lua_getglobal(L, "__program");
      auto prog = cast(Program*) lua_touserdata(L, -1);
      prog.machine.screens[0].pixmap.fgColor = cast(ubyte) cindex;
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
      prog.machine.screens[0].pixmap.plot(cast(uint) x, cast(uint) y);
      return 0;
    }

    lua_register(lua, "plot", &plot);
  }

}
