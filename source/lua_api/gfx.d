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
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.pixmap.cls();
    return 0;
  }

  lua_register(lua, "_", &gfx_cls);
  luaL_dostring(lua, "gfx.cls = _");

  /// gfx.setcolor(color, red, green, blue)
  extern (C) int gfx_setcolor(lua_State* L) @trusted
  {
    const c = lua_tointeger(L, -4);
    const r = lua_tonumber(L, -3);
    const g = lua_tonumber(L, -2);
    const b = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.pixmap.setColor(cast(uint) c, cast(ubyte) r, cast(ubyte) g, cast(ubyte) b);
    return 0;
  }

  lua_register(lua, "_", &gfx_setcolor);
  luaL_dostring(lua, "gfx.setcolor = _");

  /// gfx.getcolor(color, channel): value
  extern (C) int gfx_getcolor(lua_State* L) @trusted
  {
    const col = lua_tointeger(L, -2);
    const chan = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    const i = cast(uint)((col * 3 + chan) % prog.activeViewport.pixmap.palette.length);
    lua_pushinteger(L, prog.activeViewport.pixmap.palette[i] % 16);
    return 1;
  }

  lua_register(lua, "_", &gfx_getcolor);
  luaL_dostring(lua, "gfx.getcolor = _");

  /// gfx.fgcolor(index)
  extern (C) int gfx_fgcolor(lua_State* L) @trusted
  {
    const cindex = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.fgColor = cast(ubyte) cindex;
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "_", &gfx_fgcolor);
  luaL_dostring(lua, "gfx.fgcolor = _");

  /// gfx.bgcolor(index)
  extern (C) int gfx_bgcolor(lua_State* L) @trusted
  {
    const cindex = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.bgColor = cast(ubyte) cindex;
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "_", &gfx_bgcolor);
  luaL_dostring(lua, "gfx.bgcolor = _");

  /// gfx.pget(x, y): color
  extern (C) int gfx_pget(lua_State* L) @trusted
  {
    const x = lua_tonumber(L, -2);
    const y = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    lua_pushinteger(L, prog.activeViewport.pixmap.pget(cast(uint) x, cast(uint) y));
    return 1;
  }

  lua_register(lua, "_", &gfx_pget);
  luaL_dostring(lua, "gfx.pget = _");

  /// gfx.plot(x, y)
  extern (C) int gfx_plot(lua_State* L) @trusted
  {
    const x = lua_tonumber(L, -2);
    const y = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.plot(cast(uint) x, cast(uint) y);
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "_", &gfx_plot);
  luaL_dostring(lua, "gfx.plot = _");

  /// gfx.bar(x, y, width, height)
  extern (C) int gfx_bar(lua_State* L) @trusted
  {
    const x = lua_tonumber(L, -4);
    const y = lua_tonumber(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    prog.activeViewport.pixmap.bar(cast(int) x, cast(int) y, cast(uint) width, cast(uint) height);
    return 0;
  }

  lua_register(lua, "_", &gfx_bar);
  luaL_dostring(lua, "gfx.bar = _");

  /// gfx.line(x1, y1, x2, y2)
  extern (C) int gfx_line(lua_State* L) @trusted
  {
    const x1 = lua_tonumber(L, -4);
    const y1 = lua_tonumber(L, -3);
    const x2 = lua_tonumber(L, -2);
    const y2 = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    prog.activeViewport.pixmap.line(cast(int) x1, cast(int) y1, cast(int) x2, cast(int) y2);
    return 0;
  }

  lua_register(lua, "_", &gfx_line);
  luaL_dostring(lua, "gfx.line = _");
}
