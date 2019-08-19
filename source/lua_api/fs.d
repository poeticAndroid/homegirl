module lua_api.fs;

import std.string;
import std.file;
import std.path;
import std.conv;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register filesystem functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "fs = {}");

  /// fs.isfile(filename): confirmed
  extern (C) int fs_isfile(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      lua_pushboolean(L, exists(prog.actualFile(filename)) && isFile(prog.actualFile(filename)));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_isfile);
  luaL_dostring(lua, "fs.isfile = _");

  /// fs.isdir(filename): confirmed
  extern (C) int fs_isdir(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      lua_pushboolean(L, exists(prog.actualFile(filename)) && isDir(prog.actualFile(filename)));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_isdir);
  luaL_dostring(lua, "fs.isdir = _");

  /// fs.read(filename): string
  extern (C) int fs_read(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      ubyte[] bin = cast(ubyte[]) read(prog.actualFile(filename));
      lua_pushlstring(L, cast(char*) bin, bin.length);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_read);
  luaL_dostring(lua, "fs.read = _");

  /// fs.write(filename, string): success
  extern (C) int fs_write(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    size_t len;
    auto str = lua_tolstring(L, 2, &len);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      ubyte[] bin;
      bin.length = len;
      for (uint i = 0; i < len; i++)
        bin[i] = cast(ubyte) str[i];
      write(prog.actualFile(filename), bin);
      lua_pushboolean(L, true);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_write);
  luaL_dostring(lua, "fs.write = _");

  /// fs.delete(filename): success
  extern (C) int fs_delete(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      string path = prog.actualFile(filename);
      if (exists(path))
      {
        if (isDir(path))
          rmdirRecurse(path);
        else
          remove(path);
      }
      lua_pushboolean(L, true);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_delete);
  luaL_dostring(lua, "fs.delete = _");

  /// fs.list(dirname): entries[]
  extern (C) int fs_list(lua_State* L) @trusted
  {
    auto dirname = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      string[] entries;
      foreach (string name; dirEntries(prog.actualFile(dirname), SpanMode.shallow))
        entries ~= name;
      lua_createtable(L, cast(uint) entries.length, 0);
      for (uint i = 0; i < entries.length; i++)
      {
        if (isDir(entries[i]))
          entries[i] = baseName(entries[i]) ~ "/";
        else
          entries[i] = baseName(entries[i]);
        lua_pushstring(L, toStringz(entries[i]));
        lua_rawseti(L, -2, i + 1);
      }
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_list);
  luaL_dostring(lua, "fs.list = _");

  /// fs.drives(): drivenames[]
  extern (C) int fs_drives(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      string[] entries = prog.machine.drives.keys();
      lua_createtable(L, cast(uint) entries.length, 0);
      for (uint i = 0; i < entries.length; i++)
      {
        lua_pushstring(L, toStringz(entries[i]));
        lua_rawseti(L, -2, i + 1);
      }
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_drives);
  luaL_dostring(lua, "fs.drives = _");

  /// fs.cd([dirname]): dirname
  extern (C) int fs_cd(lua_State* L) @trusted
  {
    auto dirname = to!string(lua_tostring(L, 1));
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (set)
      {
        if (!exists(prog.actualFile(dirname)) || !isDir(prog.actualFile(dirname)))
        {
          lua_pushnil(L);
          return 1;
        }
        prog.cwd = prog.resolve(dirname);
        if (prog.cwd.length > 0 && prog.cwd[$ - 1 .. $] != ":")
          prog.cwd ~= "/";
      }
      lua_pushstring(L, toStringz(prog.cwd));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_cd);
  luaL_dostring(lua, "fs.cd = _");

  /// fs.mkdir(dirname): success
  extern (C) int fs_mkdir(lua_State* L) @trusted
  {
    auto dirname = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      mkdirRecurse(prog.actualFile(dirname));
      lua_pushboolean(L, true);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &fs_mkdir);
  luaL_dostring(lua, "fs.mkdir = _");
}
