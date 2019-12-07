module lua_api.fs;

import std.stdio;
import std.string;
import std.algorithm;
import std.file;
import std.path;
import std.conv;
import std.datetime;
import std.uri;
import bindbc.lua;

import machine;
import program;

/// fs.drives(): drivenames[]
int fs_drives(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
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

/// fs.mount(drive, url): success
int fs_mount(lua_State* L) nothrow
{
  auto drive = to!string(lua_tostring(L, 1));
  const path = to!string(lua_tostring(L, 2));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!drive)
      throw new Exception("illegal drive name!");
    drive = toUpper(prog.machine.getDrive(drive ~ ":", ""));
    if (prog.machine.net.isUrl(path))
    {
      if (!prog.hasPermission(Permissions.mountRemoteDrives))
        throw new Exception("no permission to mount remote drives!");
      prog.machine.showBusy();
      prog.machine.mountRemoteDrive(drive, path);
    }
    else
    {
      if (!prog.hasPermission(Permissions.mountLocalDrives))
        throw new Exception("no permission to mount local drives!");
      prog.machine.showBusy();
      prog.machine.mountLocalDrive(drive, path);
    }
    lua_pushboolean(L, true);
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/// fs.unmount(drive[, force]): success
int fs_unmount(lua_State* L) nothrow
{
  auto drive = to!string(lua_tostring(L, 1));
  const force = lua_toboolean(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!drive)
      throw new Exception("illegal drive name!");
    drive = toUpper(prog.machine.getDrive(drive ~ ":", ""));
    if (prog.drive != drive && !prog.hasPermission(Permissions.unmountDrives))
      throw new Exception("no permission to unmount other drives!");
    prog.machine.unmountDrive(drive, force != 0);
    lua_pushboolean(L, true);
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/// fs.isfile(filename): confirmed
int fs_isfile(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    lua_pushboolean(L, exists(prog.actualFile(filename)) && isFile(prog.actualFile(filename)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// fs.isdir(filename): confirmed
int fs_isdir(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    lua_pushboolean(L, exists(prog.actualFile(filename, true))
        && isDir(prog.actualFile(filename, true)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// fs.size(filename): bytes
int fs_size(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    lua_pushinteger(L, getSize(prog.actualFile(filename)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// fs.time(filename): hour, minute, second, UTCoffset
int fs_time(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    SysTime accessed, modified;
    getTimes(prog.actualFile(filename), accessed, modified);
    lua_pushinteger(L, modified.hour);
    lua_pushinteger(L, modified.minute);
    lua_pushinteger(L, modified.second);
    lua_pushinteger(L, modified.utcOffset.total!"minutes");
    return 4;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// fs.date(filename): year, month, date, weekday
int fs_date(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    SysTime accessed, modified;
    getTimes(prog.actualFile(filename), accessed, modified);
    lua_pushinteger(L, modified.year);
    lua_pushinteger(L, modified.month);
    lua_pushinteger(L, modified.day);
    lua_pushinteger(L, modified.dayOfWeek);
    return 4;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// fs.read(filename): string
int fs_read(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
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

/// fs.write(filename, string): success
int fs_write(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    auto filename = toLower(to!string(lua_tostring(L, 1)));
    size_t len;
    auto str = lua_tolstring(L, 2, &len);

    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.writeOtherDrives))
      throw new Exception("no permission to write to other drives!");
    prog.machine.showBusy();
    ubyte[] bin;
    bin.length = len;
    for (uint i = 0; i < len; i++)
      bin[i] = cast(ubyte) str[i];
    std.file.write(prog.actualFile(filename), bin);
    lua_pushboolean(L, prog.machine.syncPath(prog.resolve(filename)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/// fs.post(filename, request, type): response
int fs_post(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  auto request = to!string(lua_tostring(L, 2));
  auto type = to!string(lua_tostring(L, 3));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.writeOtherDrives))
      throw new Exception("no permission to write to other drives!");
    prog.machine.showBusy();
    ubyte[] bin = prog.machine.postPath(prog.resolve(filename), request, type);
    lua_pushlstring(L, cast(char*) bin, bin.length);
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// fs.rename(filename, newname): success
int fs_rename(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    auto filename = to!string(lua_tostring(L, 1));
    auto newname = toLower(to!string(lua_tostring(L, 2)));

    filename = prog.resolve(filename);
    newname = prog.resolve(newname);
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.writeOtherDrives))
      throw new Exception("no permission to write to other drives!");
    if (prog.machine.getDrive(filename) != prog.machine.getDrive(newname))
      throw new Exception("cannot rename across drives!");
    prog.machine.showBusy();
    string path = prog.actualFile(filename, true);
    string newpath = prog.actualFile(newname, true);
    bool found = false;
    if (exists(path) && isDir(path))
    {
      rename(path, newpath);
      found = true;
    }
    path = prog.actualFile(filename, false);
    newpath = prog.actualFile(newname, false);
    if (exists(path))
    {
      rename(path, newpath);
      found = true;
    }
    if (!found)
      throw new Exception("file not found!");
    lua_pushboolean(L, prog.machine.syncPath(filename, newname));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/// fs.delete(filename): success
int fs_delete(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.writeOtherDrives))
      throw new Exception("no permission to write to other drives!");
    prog.machine.showBusy();
    string path = prog.actualFile(filename, true);
    if (exists(path) && isDir(path))
      rmdirRecurse(path);
    path = prog.actualFile(filename, false);
    if (exists(path))
      remove(path);
    lua_pushboolean(L, prog.machine.syncPath(prog.resolve(filename)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/// fs.list(dirname): entries[]
int fs_list(lua_State* L) nothrow
{
  auto dirname = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(dirname) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    string[] entries;
    foreach (string name; dirEntries(prog.actualFile(dirname, true), SpanMode.shallow))
    {
      if (name.length >= 6 && name[$ - 6 .. $] == ".~void")
      {
        SysTime accessTime, modificationTime, now;
        getTimes(name, accessTime, modificationTime);
        now = Clock.currTime();
        const age = now.toUnixTime() - modificationTime.toUnixTime();
        if (age > 600)
        {
          std.file.remove(name);
        }
      }
      else
      {
        if (name.length >= 5 && name[$ - 5 .. $] == ".~dir")
        {
          auto _i = entries.countUntil(name[0 .. $ - 5] ~ ".~file");
          if (_i >= 0)
            entries = entries.remove(_i);
        }
        if (name.length >= 6 && name[$ - 6 .. $] == ".~file")
        {
          if (entries.countUntil(name[0 .. $ - 6] ~ ".~dir") < 0)
            entries ~= name;
        }
        else
          entries ~= name;
      }
    }
    lua_createtable(L, cast(uint) entries.length, 0);
    for (uint i = 0; i < entries.length; i++)
    {
      if (isDir(entries[i]))
        entries[i] = baseName(decodeComponent(entries[i]), ".~dir") ~ "/";
      else
        entries[i] = baseName(decodeComponent(entries[i]), ".~file");
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

/// fs.cd([dirname]): dirname
int fs_cd(lua_State* L) nothrow
{
  auto dirname = to!string(lua_tostring(L, 1));
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (set)
    {
      if (!prog.isOnOriginDrive(dirname) && !prog.hasPermission(Permissions.readOtherDrives))
        throw new Exception("no permission to read other drives!");
      prog.machine.showBusy();
      if (!exists(prog.actualFile(dirname, true)) || !isDir(prog.actualFile(dirname, true)))
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

/// fs.mkdir(dirname): success
int fs_mkdir(lua_State* L) nothrow
{
  auto dirname = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(dirname) && !prog.hasPermission(Permissions.writeOtherDrives))
      throw new Exception("no permission to write to other drives!");
    prog.machine.showBusy();
    mkdirRecurse(prog.actualFile(dirname, true));
    lua_pushboolean(L, prog.machine.syncPath(prog.resolve(dirname)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/**
  register filesystem functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "fs = {}");

  lua_register(lua, "_", &fs_drives);
  luaL_dostring(lua, "fs.drives = _");

  lua_register(lua, "_", &fs_mount);
  luaL_dostring(lua, "fs.mount = _");

  lua_register(lua, "_", &fs_unmount);
  luaL_dostring(lua, "fs.unmount = _");

  lua_register(lua, "_", &fs_isfile);
  luaL_dostring(lua, "fs.isfile = _");

  lua_register(lua, "_", &fs_isdir);
  luaL_dostring(lua, "fs.isdir = _");

  lua_register(lua, "_", &fs_size);
  luaL_dostring(lua, "fs.size = _");

  lua_register(lua, "_", &fs_time);
  luaL_dostring(lua, "fs.time = _");

  lua_register(lua, "_", &fs_date);
  luaL_dostring(lua, "fs.date = _");

  lua_register(lua, "_", &fs_read);
  luaL_dostring(lua, "fs.read = _");

  lua_register(lua, "_", &fs_write);
  luaL_dostring(lua, "fs.write = _");

  lua_register(lua, "_", &fs_post);
  luaL_dostring(lua, "fs.post = _");

  lua_register(lua, "_", &fs_rename);
  luaL_dostring(lua, "fs.rename = _");

  lua_register(lua, "_", &fs_delete);
  luaL_dostring(lua, "fs.delete = _");

  lua_register(lua, "_", &fs_list);
  luaL_dostring(lua, "fs.list = _");

  lua_register(lua, "_", &fs_cd);
  luaL_dostring(lua, "fs.cd = _");

  lua_register(lua, "_", &fs_mkdir);
  luaL_dostring(lua, "fs.mkdir = _");
}
