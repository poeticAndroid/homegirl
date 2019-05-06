module lua_api;

import std.stdio;
import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register some functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;

  //Setup the userdata
  auto prog = cast(Program*) lua_newuserdata(lua, Program.sizeof);
  *prog = program;
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

  /// print(message)
  extern (C) int print(lua_State* L) @trusted
  {
    const msg = lua_tostring(L, -1);
    writeln("Program says: " ~ fromStringz(msg));
    return 0;
  }

  lua_register(lua, "print", &print);

  /// int createscreen(mode, colorbits)
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

  /// int createviewport(parent, left, top, width, height)
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

  /// removeviewport(vpID)
  extern (C) int removeviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeViewport(cast(uint) vpId);
    return 0;
  }

  lua_register(lua, "removeviewport", &removeviewport);

  /// setfgcolor(index)
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

  /// setbgcolor(index)
  extern (C) int setbgcolor(lua_State* L) @trusted
  {
    const cindex = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.bgColor = cast(ubyte) cindex;
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "setbgcolor", &setbgcolor);

  /// plot(x, y)
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
