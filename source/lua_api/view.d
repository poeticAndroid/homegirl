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
  extern (C) int view_createscreen(lua_State* L) @trusted
  {
    const mode = lua_tointeger(L, -2);
    const colorBits = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createScreen(cast(ubyte) mode, cast(ubyte) colorBits));
    return 1;
  }

  lua_register(lua, "_", &view_createscreen);
  luaL_dostring(lua, "view.newscreen = _");

  /// view.screenmode(screenID, mode, colorbits)
  extern (C) int view_screenmode(lua_State* L) @trusted
  {
    const screenId = lua_tointeger(L, -3);
    const mode = lua_tointeger(L, -2);
    const colorBits = lua_tointeger(L, -1);
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
  extern (C) int view_create(lua_State* L) @trusted
  {
    const parentId = lua_tointeger(L, -5);
    const left = lua_tonumber(L, -4);
    const top = lua_tonumber(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createViewport(cast(uint) parentId, cast(int) left,
        cast(int) top, cast(uint) width, cast(uint) height));
    return 1;
  }

  lua_register(lua, "_", &view_create);
  luaL_dostring(lua, "view.new = _");

  /// view.active(vpID)
  extern (C) int view_active(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
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

  lua_register(lua, "_", &view_active);
  luaL_dostring(lua, "view.active = _");

  /// view.move(vpID, left, top)
  extern (C) int view_move(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -3);
    const left = lua_tonumber(L, -2);
    const top = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.move(cast(int) left, cast(int) top);
    return 0;
  }

  lua_register(lua, "_", &view_move);
  luaL_dostring(lua, "view.move = _");

  /// view.resize(vpID, left, top)
  extern (C) int view_resize(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.resize(cast(uint) width, cast(uint) height);
    return 0;
  }

  lua_register(lua, "_", &view_resize);
  luaL_dostring(lua, "view.resize = _");

  /// view.show(vpID, visible)
  extern (C) int view_show(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -2);
    const visible = lua_toboolean(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.visible = cast(bool) visible;
    return 0;
  }

  lua_register(lua, "_", &view_show);
  luaL_dostring(lua, "view.show = _");

  /// view.left(vpID): left
  extern (C) int view_left(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].left);
    return 1;
  }

  lua_register(lua, "_", &view_left);
  luaL_dostring(lua, "view.left = _");

  /// view.top(vpID): top
  extern (C) int view_top(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].top);
    return 1;
  }

  lua_register(lua, "_", &view_top);
  luaL_dostring(lua, "view.top = _");

  /// view.width(vpID): width
  extern (C) int view_width(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].pixmap.width);
    return 1;
  }

  lua_register(lua, "_", &view_width);
  luaL_dostring(lua, "view.width = _");

  /// view.height(vpID): height
  extern (C) int view_height(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].pixmap.height);
    return 1;
  }

  lua_register(lua, "_", &view_height);
  luaL_dostring(lua, "view.height = _");

  /// view.isfocused(vpID): focused
  extern (C) int view_isfocused(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushboolean(L,
        prog.viewports[cast(uint) vpId].containsViewport(prog.machine.focusedViewport));
    return 1;
  }

  lua_register(lua, "_", &view_isfocused);
  luaL_dostring(lua, "view.isfocused = _");

  /// view.focus(vpID)
  extern (C) int view_focus(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.focusViewport(prog.viewports[cast(uint) vpId]);
    return 1;
  }

  lua_register(lua, "_", &view_focus);
  luaL_dostring(lua, "view.focus = _");

  /// view.remove(vpID)
  extern (C) int view_remove(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeViewport(cast(uint) vpId);
    return 0;
  }

  lua_register(lua, "_", &view_remove);
  luaL_dostring(lua, "view.remove = _");
}
