module lua_api.gfx;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register gfx functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "gfx = {}");

  /// gfx.cls()
  extern (C) int gfx_cls(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_cls);
  luaL_dostring(lua, "gfx.cls = _");

  /// gfx.palette(color[, red, green, blue]): red, green, blue
  extern (C) int gfx_palette(lua_State* L) @trusted
  {
    const c = lua_tointeger(L, 1);
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
        prog.activeViewport.pixmap.setColor(cast(uint) c, cast(ubyte) r,
            cast(ubyte) g, cast(ubyte) b);
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

  lua_register(lua, "_", &gfx_palette);
  luaL_dostring(lua, "gfx.palette = _");

  /// gfx.fgcolor([color]): color
  extern (C) int gfx_fgcolor(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_fgcolor);
  luaL_dostring(lua, "gfx.fgcolor = _");

  /// gfx.bgcolor([color]): color
  extern (C) int gfx_bgcolor(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_bgcolor);
  luaL_dostring(lua, "gfx.bgcolor = _");

  /// gfx.pixel(x, y[, color]): color
  extern (C) int gfx_pixel(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_pixel);
  luaL_dostring(lua, "gfx.pixel = _");

  /// gfx.plot(x, y)
  extern (C) int gfx_plot(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_plot);
  luaL_dostring(lua, "gfx.plot = _");

  /// gfx.bar(x, y, width, height)
  extern (C) int gfx_bar(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_bar);
  luaL_dostring(lua, "gfx.bar = _");

  /// gfx.line(x1, y1, x2, y2)
  extern (C) int gfx_line(lua_State* L) @trusted
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

  lua_register(lua, "_", &gfx_line);
  luaL_dostring(lua, "gfx.line = _");
}
