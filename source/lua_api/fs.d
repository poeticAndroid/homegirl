module lua_api.fs;

import std.string;
import std.file;
import std.path;
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

  /// fs.read(filename): string
  extern (C) int fs_read(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      lua_pushstring(L, toStringz(readText(prog.actualFile(cast(string) filename))));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &fs_read);
  luaL_dostring(lua, "fs.read = _");

  /// fs.write(filename, string)
  extern (C) int fs_write(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, 1));
    auto str = fromStringz(lua_tostring(L, 2));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      write(prog.actualFile(cast(string) filename), str);
      return 0;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &fs_write);
  luaL_dostring(lua, "fs.write = _");

  /// fs.delete(filename)
  extern (C) int fs_delete(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      string path = prog.actualFile(cast(string) filename);
      if (exists(path))
      {
        if (isDir(path))
          rmdirRecurse(path);
        else
          remove(path);
      }
      return 0;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &fs_delete);
  luaL_dostring(lua, "fs.delete = _");

  /// fs.list(dirname)
  extern (C) int fs_list(lua_State* L) @trusted
  {
    auto dirname = fromStringz(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      string[] entries;
      foreach (string name; dirEntries(prog.actualFile(cast(string) dirname), SpanMode.shallow))
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
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &fs_list);
  luaL_dostring(lua, "fs.list = _");

  /// fs.cd([dirname]): dirname
  extern (C) int fs_cd(lua_State* L) @trusted
  {
    auto dirname = fromStringz(lua_tostring(L, 1));
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (set)
      {
        if (isDir(prog.actualFile(cast(string) dirname)))
          prog.cwd = prog.resolve(cast(string) dirname) ~ "/";
        else
          throw new Throwable("Directory doesn't exist!");
      }
      lua_pushstring(L, toStringz(prog.cwd));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &fs_cd);
  luaL_dostring(lua, "fs.cd = _");

  /// fs.mkdir(dirname)
  extern (C) int fs_mkdir(lua_State* L) @trusted
  {
    auto dirname = fromStringz(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      mkdirRecurse(prog.actualFile(cast(string) dirname));
      return 0;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &fs_mkdir);
  luaL_dostring(lua, "fs.mkdir = _");
}
