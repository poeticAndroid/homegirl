module lua_api._;

import std.stdio;
import std.string;
import std.path;
import riverd.lua;
import riverd.lua.types;

import program;
import viewport;
import pixmap;

import lua_api.sys;
import lua_api.fs;
import lua_api.view;
import lua_api.input;
import lua_api.audio;
import lua_api.image;
import lua_api.gfx;
import lua_api.text;

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
  luaL_dostring(lua, q"{
    io = NIL
    os = NIL
    package = NIL

    function _init()
    end
    function _step()
      sys.exit(0)
    end
    function _shutdown()
    end
  }");

  extern (C) int panic(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.shutdown(-1);
    writeln("Shit hit the fan!");
    return 0;
  }

  lua_atpanic(lua, &panic);

  /// dofile(filename)
  extern (C) int dofile(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, -1);
    writeln("dofile not yet implemented!");
    return 0;
  }

  // lua_register(lua, "dofile", &dofile);

  /// loadfile(filename)
  extern (C) int loadfile(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, -1);
    writeln("loadfile not yet implemented!");
    return 0;
  }

  lua_register(lua, "loadfile", &loadfile);

  /// print(message)
  extern (C) int print(lua_State* L) @trusted
  {
    const msg = lua_tostring(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    writeln(baseName(prog.filename) ~ ": " ~ fromStringz(msg));
    return 0;
  }

  lua_register(lua, "print", &print);

  /// require(filename)
  extern (C) int require(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, -1);
    writeln("require not yet implemented!");
    return 0;
  }

  lua_register(lua, "require", &require);

  lua_api.sys.registerFunctions(program);
  lua_api.fs.registerFunctions(program);
  lua_api.view.registerFunctions(program);
  lua_api.input.registerFunctions(program);
  lua_api.audio.registerFunctions(program);
  lua_api.image.registerFunctions(program);
  lua_api.gfx.registerFunctions(program);
  lua_api.text.registerFunctions(program);

  luaL_dostring(lua, "_ = NIL");
}
