module lua_api.sys;

import std.string;
import std.conv;
import std.datetime;
import bindbc.lua;

import machine;
import program;

/// sys.read(): string
int sys_read(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    lua_pushstring(L, toStringz(prog.read(0)));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.write(string)
int sys_write(lua_State* L) nothrow
{
  const str = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    prog.write(1, str);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.err(string)
int sys_err(lua_State* L) nothrow
{
  const str = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    prog.write(2, str);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.stepinterval([milliseconds]): milliseconds
int sys_stepinterval(lua_State* L) nothrow
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

/// sys.listenv(): keys[]
int sys_listenv(lua_State* L) nothrow
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

/// sys.env(key[, value]): value
int sys_env(lua_State* L) nothrow
{
  const key = to!string(lua_tostring(L, 1));
  const value = to!string(lua_tostring(L, 2));
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (set && prog.hasPermission(Permissions.writeEnv))
      prog.machine.env[key] = value;
    string val = prog.machine.env.get(key, null);
    if (val && prog.hasPermission(Permissions.readEnv))
      lua_pushstring(L, toStringz(val));
    else
      lua_pushnil(L);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.time(): hour, minute, second, UTCoffset
int sys_time(lua_State* L) nothrow
{
  try
  {
    SysTime now = Clock.currTime();
    lua_pushinteger(L, cast(int) now.hour);
    lua_pushinteger(L, cast(int) now.minute);
    lua_pushinteger(L, cast(int) now.second);
    lua_pushinteger(L, cast(int) now.utcOffset.total!"minutes");
    return 4;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.date(): year, month, date, weekday
int sys_date(lua_State* L) nothrow
{
  try
  {
    SysTime now = Clock.currTime();
    lua_pushinteger(L, cast(int) now.year);
    lua_pushinteger(L, cast(int) now.month);
    lua_pushinteger(L, cast(int) now.day);
    lua_pushinteger(L, cast(int) now.dayOfWeek);
    return 4;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.exit([code])
int sys_exit(lua_State* L) nothrow
{
  const code = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    prog.shutdown(cast(int) code);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.permissions(drive[, perms]): perms
int sys_permissions(lua_State* L) nothrow
{
  auto drive = to!string(lua_tostring(L, 1));
  const perms = lua_tointeger(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    drive = toLower(prog.machine.getDrive(drive ~ ":", ""));
    if ((set || prog.drive != drive) && !prog.hasPermission(Permissions.managePermissions))
      throw new Exception("no permission to manage permissions!");
    if (set)
      prog.machine.perms[drive] = cast(uint) perms;
    lua_pushinteger(L, cast(int) prog.machine.perms.get(drive, 0));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.requestedpermissions(drive[, perms]): perms
int sys_requestedpermissions(lua_State* L) nothrow
{
  auto drive = to!string(lua_tostring(L, 1));
  const perms = lua_tointeger(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    drive = toLower(prog.machine.getDrive(drive ~ ":", ""));
    if (prog.drive != drive && !prog.hasPermission(Permissions.managePermissions))
      throw new Exception("no permission to manage permissions!");
    if (set)
      prog.machine.reqPerms[drive] = cast(uint) perms;
    lua_pushinteger(L, cast(int) prog.machine.reqPerms.get(drive, 0));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.lookbusy()
int sys_lookbusy(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    prog.machine.showBusy();
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.memoryusage(): bytesinuse
int sys_memoryusage(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  lua_pushinteger(L, cast(int) prog.machine.memoryUsed);
  return 1;
}

/// sys.exec(filename[, args[][, cwd]]): success
int sys_exec(lua_State* L) nothrow
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
    prog.machine.showBusy();
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

/// sys.killall(programname): count
int sys_killall(lua_State* L) nothrow
{
  const filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.managePrograms))
      throw new Exception("no permission to manage other programs!");
    lua_pushinteger(L, cast(int) prog.machine.killAll(prog.resolve(filename)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// sys.startchild(filename[, args[]]): child
int sys_startchild(lua_State* L) nothrow
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
    prog.machine.showBusy();
    lua_pushinteger(L, cast(int) prog.startChild(prog.resolve(filename), args));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// sys.childrunning(child): bool
int sys_childrunning(lua_State* L) nothrow
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

/// sys.childexitcode(child): int
int sys_childexitcode(lua_State* L) nothrow
{
  const child = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (child >= prog.children.length || !prog.children[cast(uint) child])
      throw new Exception("Invalid child!");
    lua_pushinteger(L, cast(int) prog.children[cast(uint) child].exitcode);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// sys.writetochild(child, str)
int sys_writetochild(lua_State* L) nothrow
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

/// sys.readfromchild(child): str
int sys_readfromchild(lua_State* L) nothrow
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

/// sys.errorfromchild(child): str
int sys_errorfromchild(lua_State* L) nothrow
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

/// sys.killchild(child)
int sys_killchild(lua_State* L) nothrow
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

/// sys.forgetchild(child)
int sys_forgetchild(lua_State* L) nothrow
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

/**
  register system functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "sys = {}");

  lua_register(lua, "_", &sys_read);
  luaL_dostring(lua, "sys.read = _");

  lua_register(lua, "_", &sys_write);
  luaL_dostring(lua, "sys.write = _");

  lua_register(lua, "_", &sys_err);
  luaL_dostring(lua, "sys.err = _");

  lua_register(lua, "_", &sys_stepinterval);
  luaL_dostring(lua, "sys.stepinterval = _");

  lua_register(lua, "_", &sys_listenv);
  luaL_dostring(lua, "sys.listenv = _");

  lua_register(lua, "_", &sys_env);
  luaL_dostring(lua, "sys.env = _");

  lua_register(lua, "_", &sys_time);
  luaL_dostring(lua, "sys.time = _");

  lua_register(lua, "_", &sys_date);
  luaL_dostring(lua, "sys.date = _");

  lua_register(lua, "_", &sys_exit);
  luaL_dostring(lua, "sys.exit = _");

  lua_register(lua, "_", &sys_permissions);
  luaL_dostring(lua, "sys.permissions = _");

  lua_register(lua, "_", &sys_requestedpermissions);
  luaL_dostring(lua, "sys.requestedpermissions = _");

  lua_register(lua, "_", &sys_lookbusy);
  luaL_dostring(lua, "sys.lookbusy = _");

  lua_register(lua, "_", &sys_memoryusage);
  luaL_dostring(lua, "sys.memoryusage = _");

  lua_register(lua, "_", &sys_exec);
  luaL_dostring(lua, "sys.exec = _");

  lua_register(lua, "_", &sys_killall);
  luaL_dostring(lua, "sys.killall = _");

  lua_register(lua, "_", &sys_startchild);
  luaL_dostring(lua, "sys.startchild = _");

  lua_register(lua, "_", &sys_childrunning);
  luaL_dostring(lua, "sys.childrunning = _");

  lua_register(lua, "_", &sys_childexitcode);
  luaL_dostring(lua, "sys.childexitcode = _");

  lua_register(lua, "_", &sys_writetochild);
  luaL_dostring(lua, "sys.writetochild = _");

  lua_register(lua, "_", &sys_readfromchild);
  luaL_dostring(lua, "sys.readfromchild = _");

  lua_register(lua, "_", &sys_errorfromchild);
  luaL_dostring(lua, "sys.errorfromchild = _");

  lua_register(lua, "_", &sys_killchild);
  luaL_dostring(lua, "sys.killchild = _");

  lua_register(lua, "_", &sys_forgetchild);
  luaL_dostring(lua, "sys.forgetchild = _");
}
