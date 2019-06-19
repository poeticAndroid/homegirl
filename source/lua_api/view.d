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

  /// view.createscreen(mode, colorbits): id
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
  luaL_dostring(lua, "view.createscreen = _");

  /// view.changescreenmode(screenID, mode, colorbits)
  extern (C) int view_changescreenmode(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_changescreenmode);
  luaL_dostring(lua, "view.changescreenmode = _");

  /// view.createviewport(parent, left, top, width, height): id
  extern (C) int view_createviewport(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_createviewport);
  luaL_dostring(lua, "view.createviewport = _");

  /// view.activeviewport(vpID)
  extern (C) int view_activeviewport(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_activeviewport);
  luaL_dostring(lua, "view.activeviewport = _");

  /// view.moveviewport(vpID, left, top)
  extern (C) int view_moveviewport(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_moveviewport);
  luaL_dostring(lua, "view.moveviewport = _");

  /// view.resizeviewport(vpID, left, top)
  extern (C) int view_resizeviewport(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_resizeviewport);
  luaL_dostring(lua, "view.resizeviewport = _");

  /// view.showviewport(vpID, visible)
  extern (C) int view_showviewport(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_showviewport);
  luaL_dostring(lua, "view.showviewport = _");

  /// view.viewportleft(vpID): left
  extern (C) int view_viewportleft(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].left);
    return 1;
  }

  lua_register(lua, "_", &view_viewportleft);
  luaL_dostring(lua, "view.viewportleft = _");

  /// view.viewporttop(vpID): top
  extern (C) int view_viewporttop(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].top);
    return 1;
  }

  lua_register(lua, "_", &view_viewporttop);
  luaL_dostring(lua, "view.viewporttop = _");

  /// view.viewportwidth(vpID): width
  extern (C) int view_viewportwidth(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].pixmap.width);
    return 1;
  }

  lua_register(lua, "_", &view_viewportwidth);
  luaL_dostring(lua, "view.viewportwidth = _");

  /// view.viewportheight(vpID): height
  extern (C) int view_viewportheight(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].pixmap.height);
    return 1;
  }

  lua_register(lua, "_", &view_viewportheight);
  luaL_dostring(lua, "view.viewportheight = _");

  /// view.viewportfocused(vpID): focused
  extern (C) int view_viewportfocused(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushboolean(L,
        prog.viewports[cast(uint) vpId].containsViewport(prog.machine.focusedViewport));
    return 1;
  }

  lua_register(lua, "_", &view_viewportfocused);
  luaL_dostring(lua, "view.viewportfocused = _");

  /// view.focusviewport(vpID)
  extern (C) int view_focusviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.focusViewport(prog.viewports[cast(uint) vpId]);
    return 1;
  }

  lua_register(lua, "_", &view_focusviewport);
  luaL_dostring(lua, "view.focusviewport = _");

  /// view.removeviewport(vpID)
  extern (C) int view_removeviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeViewport(cast(uint) vpId);
    return 0;
  }

  lua_register(lua, "_", &view_removeviewport);
  luaL_dostring(lua, "view.removeviewport = _");
}
