module lua_api.view;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;
import viewport;

/**
  register viewport functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "view = {}");

  /// view.newscreen(mode, colorbits): id
  extern (C) int view_newscreen(lua_State* L) @trusted
  {
    const mode = lua_tointeger(L, 1);
    const colorBits = lua_tointeger(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createScreen(cast(ubyte) mode, cast(ubyte) colorBits));
    return 1;
  }

  lua_register(lua, "_", &view_newscreen);
  luaL_dostring(lua, "view.newscreen = _");

  /// view.screenmode(screenID, mode, colorbits)
  extern (C) int view_screenmode(lua_State* L) @trusted
  {
    const screenId = lua_tointeger(L, 1);
    const mode = lua_tointeger(L, 2);
    const colorBits = lua_tointeger(L, 3);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    Viewport vp = prog.machine.mainScreen;
    if (screenId > 0)
    {
      vp = prog.viewports[cast(uint) screenId];
    }
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.changeMode(cast(ubyte) mode, cast(ubyte) colorBits);
    return 0;
  }

  lua_register(lua, "_", &view_screenmode);
  luaL_dostring(lua, "view.screenmode = _");

  /// view.new(parent, left, top, width, height): id
  extern (C) int view_new(lua_State* L) @trusted
  {
    const parentId = lua_tointeger(L, 1);
    const left = lua_tonumber(L, 2);
    const top = lua_tonumber(L, 3);
    const width = lua_tonumber(L, 4);
    const height = lua_tonumber(L, 5);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createViewport(cast(uint) parentId, cast(int) left,
        cast(int) top, cast(uint) width, cast(uint) height));
    return 1;
  }

  lua_register(lua, "_", &view_new);
  luaL_dostring(lua, "view.new = _");

  /// view.activate(vpID)
  extern (C) int view_activate(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport = vp;
    return 0;
  }

  lua_register(lua, "_", &view_activate);
  luaL_dostring(lua, "view.activate = _");

  /// view.position(vpID[, left, top]): left, top
  extern (C) int view_position(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, 1);
    const left = lua_tonumber(L, 2);
    const top = lua_tonumber(L, 3);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      vp.move(cast(int) left, cast(int) top);
    lua_pushinteger(L, vp.left);
    lua_pushinteger(L, vp.top);
    return 2;
  }

  lua_register(lua, "_", &view_position);
  luaL_dostring(lua, "view.position = _");

  /// view.size(vpID[, width, height]): width, height
  extern (C) int view_size(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, 1);
    const width = lua_tonumber(L, 2);
    const height = lua_tonumber(L, 3);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      vp.resize(cast(uint) width, cast(uint) height);
    lua_pushinteger(L, vp.pixmap.width);
    lua_pushinteger(L, vp.pixmap.height);
    return 2;
  }

  lua_register(lua, "_", &view_size);
  luaL_dostring(lua, "view.size = _");

  /// view.visible(vpID[, visible]): visible
  extern (C) int view_visible(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, 1);
    const visible = lua_toboolean(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      vp.visible = cast(bool) visible;
    lua_pushboolean(L, vp.visible);
    return 1;
  }

  lua_register(lua, "_", &view_visible);
  luaL_dostring(lua, "view.visible = _");

  /// view.focused(vpID[, focused]): focused
  extern (C) int view_focused(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, 1);
    const focused = lua_toboolean(L, 2);
    const set = lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      prog.machine.focusViewport(focused ? vp : null);
    lua_pushboolean(L, vp.containsViewport(prog.machine.focusedViewport));
    return 1;
  }

  lua_register(lua, "_", &view_focused);
  luaL_dostring(lua, "view.focused = _");

  /// view.remove(vpID)
  extern (C) int view_remove(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeViewport(cast(uint) vpId);
    return 0;
  }

  lua_register(lua, "_", &view_remove);
  luaL_dostring(lua, "view.remove = _");
}
