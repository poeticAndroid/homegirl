module lua_api._basic_;

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
    file = NIL
    os = NIL
    package = { loaded = {} }

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
    auto prog = cast(Program*) lua_touserdata(L, 1);
    prog.shutdown(-1);
    writeln("Shit hit the fan!");
    return 0;
  }

  lua_atpanic(lua, &panic);

  /// dofile(filename): result
  extern (C) int dofile(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, 1);
    try
    {
      luaL_dofile(L, toStringz(prog.actualFile(cast(string) fromStringz(filename))));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "dofile", &dofile);

  /// loadfile(filename): function
  extern (C) int loadfile(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, 1);
    try
    {
      luaL_loadfile(L, toStringz(prog.actualFile(cast(string) fromStringz(filename))));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "loadfile", &loadfile);

  /// print(message)
  extern (C) int print(lua_State* L) @trusted
  {
    const msg = lua_tostring(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    writeln(baseName(prog.filename) ~ ": " ~ fromStringz(msg));
    return 0;
  }

  lua_register(lua, "print", &print);

  /// require(filename): module
  extern (C) int require(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      auto path = toStringz(prog.actualFile(cast(string) fromStringz(filename)));
      lua_getglobal(L, "package");
      lua_getfield(L, -1, "loaded");
      lua_getfield(L, -1, path);
      if (lua_isnoneornil(L, -1))
      {
        lua_pop(L, 1);
        luaL_dofile(L, toStringz(fromStringz(path) ~ ".lua"));
        lua_setfield(L, -2, path);
        lua_getfield(L, -1, path);
      }
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
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
