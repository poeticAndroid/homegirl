module lua_api.sys;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register system functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "sys = {}");

  /// sys.exit([code])
  extern (C) int sys_exit(lua_State* L) @trusted
  {
    const code = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.shutdown(cast(int) code);
    return 0;
  }

  lua_register(lua, "_", &sys_exit);
  luaL_dostring(lua, "sys.exit = _");

  /// sys.exec(filename)
  extern (C) int sys_exec(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.startProgram(prog.resolve(cast(string) fromStringz(filename)));
    return 0;
  }

  lua_register(lua, "_", &sys_exec);
  luaL_dostring(lua, "sys.exec = _");
}
