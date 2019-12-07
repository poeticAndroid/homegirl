module lua_api.gfx;

import std.string;
import bindbc.lua;

import program;

/// gfx.cls()
int gfx_cls(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    prog.activeViewport.pixmap.cls();
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.palette(color[, red, green, blue]): red, green, blue
int gfx_palette(lua_State* L) nothrow
{
  const c = lua_tonumber(L, 1);
  const r = lua_tonumber(L, 2);
  const g = lua_tonumber(L, 3);
  const b = lua_tonumber(L, 4);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.pixmap.setColor(cast(uint) c, cast(ubyte) r, cast(ubyte) g, cast(ubyte) b);
    uint i = cast(uint)(c * 3) % prog.activeViewport.pixmap.palette.length;
    lua_pushinteger(L, prog.activeViewport.pixmap.palette[i++] % 16);
    lua_pushinteger(L, prog.activeViewport.pixmap.palette[i++] % 16);
    lua_pushinteger(L, prog.activeViewport.pixmap.palette[i++] % 16);
    return 3;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.fgcolor([color]): color
int gfx_fgcolor(lua_State* L) nothrow
{
  const cindex = lua_tonumber(L, 1);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.pixmap.setFGColor(cast(ubyte) cindex);
    lua_pushinteger(L, prog.activeViewport.pixmap.fgColor);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.bgcolor([color]): color
int gfx_bgcolor(lua_State* L) nothrow
{
  const cindex = lua_tonumber(L, 1);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.pixmap.setBGColor(cast(ubyte) cindex);
    lua_pushinteger(L, prog.activeViewport.pixmap.bgColor);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.pixel(x, y[, color]): color
int gfx_pixel(lua_State* L) nothrow
{
  const x = lua_tonumber(L, 1);
  const y = lua_tonumber(L, 2);
  const c = lua_tonumber(L, 3);
  const set = 1 - lua_isnoneornil(L, 3);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.pixmap.pset(cast(uint) x, cast(uint) y, cast(ubyte) c);
    lua_pushinteger(L, prog.activeViewport.pixmap.pget(cast(uint) x, cast(uint) y));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.plot(x, y)
int gfx_plot(lua_State* L) nothrow
{
  const x = lua_tonumber(L, 1);
  const y = lua_tonumber(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    prog.activeViewport.pixmap.plot(cast(uint) x, cast(uint) y);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.bar(x, y, width, height)
int gfx_bar(lua_State* L) nothrow
{
  const x = lua_tonumber(L, 1);
  const y = lua_tonumber(L, 2);
  const width = lua_tonumber(L, 3);
  const height = lua_tonumber(L, 4);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    prog.activeViewport.pixmap.bar(cast(int) x, cast(int) y, cast(int) width, cast(int) height);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.line(x1, y1, x2, y2)
int gfx_line(lua_State* L) nothrow
{
  const x1 = lua_tonumber(L, 1);
  const y1 = lua_tonumber(L, 2);
  const x2 = lua_tonumber(L, 3);
  const y2 = lua_tonumber(L, 4);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    prog.activeViewport.pixmap.line(cast(int) x1, cast(int) y1, cast(int) x2, cast(int) y2);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// gfx.tri(x1, y1, x2, y2, x3, y3)
int gfx_tri(lua_State* L) nothrow
{
  const x1 = lua_tonumber(L, 1);
  const y1 = lua_tonumber(L, 2);
  const x2 = lua_tonumber(L, 3);
  const y2 = lua_tonumber(L, 4);
  const x3 = lua_tonumber(L, 5);
  const y3 = lua_tonumber(L, 6);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    prog.activeViewport.pixmap.triangle(cast(int) x1, cast(int) y1, cast(int) x2,
        cast(int) y2, cast(int) x3, cast(int) y3);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/**
  register gfx functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "gfx = {}");

  lua_register(lua, "_", &gfx_cls);
  luaL_dostring(lua, "gfx.cls = _");

  lua_register(lua, "_", &gfx_palette);
  luaL_dostring(lua, "gfx.palette = _");

  lua_register(lua, "_", &gfx_fgcolor);
  luaL_dostring(lua, "gfx.fgcolor = _");

  lua_register(lua, "_", &gfx_bgcolor);
  luaL_dostring(lua, "gfx.bgcolor = _");

  lua_register(lua, "_", &gfx_pixel);
  luaL_dostring(lua, "gfx.pixel = _");

  lua_register(lua, "_", &gfx_plot);
  luaL_dostring(lua, "gfx.plot = _");

  lua_register(lua, "_", &gfx_bar);
  luaL_dostring(lua, "gfx.bar = _");

  lua_register(lua, "_", &gfx_line);
  luaL_dostring(lua, "gfx.line = _");

  lua_register(lua, "_", &gfx_tri);
  luaL_dostring(lua, "gfx.tri = _");
}
