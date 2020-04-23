module lua_api._basic_;

import std.string;
import std.path;
import std.conv;
import std.file;
import bindbc.lua;

import machine;
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

int panic(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    prog.shutdown(-1);
  }
  catch (Exception err)
  {
  }
  // writeln("Shit hit the fan!");
  return 0;
}

/// dofile(filename): result
int dofile(lua_State* L) nothrow
{
  const filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    prog.doFile(filename);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// loadfile(filename): function
int loadfile(lua_State* L) nothrow
{
  const filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    auto path = prog.actualFile(filename);
    if (luaL_loadstring(L,
        toStringz(prog.machine.luaFilepathVars(prog.resolve(filename)) ~ readText(path))))
      throw new Exception("Cannot load file " ~ filename);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// print(message)
int print(lua_State* L) nothrow
{
  const msg = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    prog.write(1, msg ~ "\n");
    // writeln(prog.machine.baseName(prog.filename) ~ ": " ~ msg);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// require(filename): module
int require(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!(prog.resolve(filename).length > 10
        && prog.resolve(filename)[0 .. 9] == "sys:libs/")
        && !prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    filename = prog.resolveResource("libs", filename, ".lua");
    auto path = prog.actualFile(filename);
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "loaded");
    lua_getfield(L, -1, toStringz(prog.resolve(path)));
    if (lua_isnoneornil(L, -1))
    {
      lua_pop(L, 1);
      prog.doFile(filename);
      lua_setfield(L, -2, toStringz(path));
      lua_getfield(L, -1, toStringz(path));
    }
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

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

  lua_atpanic(lua, &panic);

  lua_register(lua, "dofile", &dofile);

  lua_register(lua, "loadfile", &loadfile);

  lua_register(lua, "print", &print);

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
