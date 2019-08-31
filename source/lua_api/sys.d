module lua_api.sys;

import std.string;
import std.conv;
import std.datetime;
import riverd.lua;
import riverd.lua.types;

import machine;
import program;

/**
  register system functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "sys = {}");

  /// sys.stepinterval([milliseconds]): milliseconds
  extern (C) int sys_stepinterval(lua_State* L) @trusted
  {
    const duration = lua_tonumber(L, 1);
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (set)
        prog.stepInterval = duration;
      lua_pushnumber(L, prog.stepInterval);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &sys_stepinterval);
  luaL_dostring(lua, "sys.stepinterval = _");

  /// sys.listenv(): keys[]
  extern (C) int sys_listenv(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.hasPermission(Permissions.readEnv))
        throw new Exception("no permission to read environment variables!");
      string[] entries = prog.machine.env.keys();
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

  lua_register(lua, "_", &sys_listenv);
  luaL_dostring(lua, "sys.listenv = _");

  /// sys.env(key[, value]): value
  extern (C) int sys_env(lua_State* L) @trusted
  {
    const key = to!string(lua_tostring(L, 1));
    const value = to!string(lua_tostring(L, 2));
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (set && prog.hasPermission(Permissions.writeEnv))
      prog.machine.env[key] = value;
    string val = prog.machine.env.get(key, null);
    if (val && prog.hasPermission(Permissions.readEnv))
      lua_pushstring(L, toStringz(val));
    else
      lua_pushnil(L);
    return 1;
  }

  lua_register(lua, "_", &sys_env);
  luaL_dostring(lua, "sys.env = _");

  /// sys.time(): hour, minute, second, UTCoffset
  extern (C) int sys_time(lua_State* L) @trusted
  {
    SysTime now = Clock.currTime();
    lua_pushinteger(L, now.hour);
    lua_pushinteger(L, now.minute);
    lua_pushinteger(L, now.second);
    lua_pushinteger(L, now.utcOffset.total!"minutes");
    return 4;
  }

  lua_register(lua, "_", &sys_time);
  luaL_dostring(lua, "sys.time = _");

  /// sys.date(): year, month, date, weekday
  extern (C) int sys_date(lua_State* L) @trusted
  {
    SysTime now = Clock.currTime();
    lua_pushinteger(L, now.year);
    lua_pushinteger(L, now.month);
    lua_pushinteger(L, now.day);
    lua_pushinteger(L, now.dayOfWeek);
    return 4;
  }

  lua_register(lua, "_", &sys_date);
  luaL_dostring(lua, "sys.date = _");

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

  /// sys.permissions(drive[, perms]): perms
  extern (C) int sys_permissions(lua_State* L) @trusted
  {
    auto drive = to!string(lua_tostring(L, 1));
    const perms = lua_tointeger(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      drive = toUpper(prog.machine.getDrive(drive ~ ":", ""));
      if ((set || prog.drive != drive) && !prog.hasPermission(Permissions.managePermissions))
        throw new Exception("no permission to manage permissions!");
      if (set)
        prog.machine.perms[drive] = cast(uint) perms;
      lua_pushinteger(L, prog.machine.perms.get(drive, 0));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_permissions);
  luaL_dostring(lua, "sys.permissions = _");

  /// sys.requestedpermissions(drive[, perms]): perms
  extern (C) int sys_requestedpermissions(lua_State* L) @trusted
  {
    auto drive = to!string(lua_tostring(L, 1));
    const perms = lua_tointeger(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      drive = toUpper(prog.machine.getDrive(drive ~ ":", ""));
      if (prog.drive != drive && !prog.hasPermission(Permissions.managePermissions))
        throw new Exception("no permission to manage permissions!");
      if (set)
        prog.machine.reqPerms[drive] = cast(uint) perms;
      lua_pushinteger(L, prog.machine.reqPerms.get(drive, 0));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_requestedpermissions);
  luaL_dostring(lua, "sys.requestedpermissions = _");

  /// sys.exec(filename[, args[][, cwd]]): success
  extern (C) int sys_exec(lua_State* L) @trusted
  {
    const filename = to!string(lua_tostring(L, 1));
    const args_len = lua_rawlen(L, 2);
    const cwd = to!string(lua_tostring(L, 3));
    string[] args;
    if (args_len)
    {
      lua_pushnil(L);
      while (lua_next(L, 2))
      {
        args ~= to!string(lua_tostring(L, -1));
        lua_pop(L, 1);
      }
    }
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
        throw new Exception("no permission to read other drives!");
      prog.machine.startProgram(prog.resolve(filename), args, cwd);
      lua_pushboolean(L, true);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushboolean(L, false);
      return 1;
    }
  }

  lua_register(lua, "_", &sys_exec);
  luaL_dostring(lua, "sys.exec = _");

  /// sys.startchild(filename[, args[]]): child
  extern (C) int sys_startchild(lua_State* L) @trusted
  {
    const filename = to!string(lua_tostring(L, 1));
    const args_len = lua_rawlen(L, 2);
    string[] args;
    if (args_len)
    {
      lua_pushnil(L);
      while (lua_next(L, 2))
      {
        args ~= to!string(lua_tostring(L, -1));
        lua_pop(L, 1);
      }
    }
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
        throw new Exception("no permission to read other drives!");
      lua_pushinteger(L, prog.startChild(prog.resolve(filename), args));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &sys_startchild);
  luaL_dostring(lua, "sys.startchild = _");

  /// sys.childrunning(child): bool
  extern (C) int sys_childrunning(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      lua_pushboolean(L, prog.children[cast(uint) child].running);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_childrunning);
  luaL_dostring(lua, "sys.childrunning = _");

  /// sys.childexitcode(child): int
  extern (C) int sys_childexitcode(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      lua_pushinteger(L, prog.children[cast(uint) child].exitcode);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  /// sys.writetochild(child, str)
  extern (C) int sys_writetochild(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    const str = to!string(lua_tostring(L, 2));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      prog.children[cast(uint) child].write(0, str);
      return 0;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_writetochild);
  luaL_dostring(lua, "sys.writetochild = _");

  /// sys.readfromchild(child): str
  extern (C) int sys_readfromchild(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    const str = to!string(lua_tostring(L, 2));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      lua_pushstring(L, toStringz(prog.children[cast(uint) child].read(1)));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_readfromchild);
  luaL_dostring(lua, "sys.readfromchild = _");

  /// sys.errorfromchild(child): str
  extern (C) int sys_errorfromchild(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    const str = to!string(lua_tostring(L, 2));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      lua_pushstring(L, toStringz(prog.children[cast(uint) child].read(2)));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_errorfromchild);
  luaL_dostring(lua, "sys.errorfromchild = _");

  /// sys.killchild(child)
  extern (C) int sys_killchild(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      prog.children[cast(uint) child].shutdown(-1);
      return 0;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_killchild);
  luaL_dostring(lua, "sys.killchild = _");

  /// sys.forgetchild(child)
  extern (C) int sys_forgetchild(lua_State* L) @trusted
  {
    const child = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (child >= prog.children.length || !prog.children[cast(uint) child])
        throw new Exception("Invalid child!");
      prog.removeChild(cast(uint) child);
      return 0;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &sys_forgetchild);
  luaL_dostring(lua, "sys.forgetchild = _");
}
