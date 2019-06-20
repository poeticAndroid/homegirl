module lua_api.fs;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register filesystem functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  /// -- not yet implemented
  luaL_dostring(lua, "fs = {}");
}
