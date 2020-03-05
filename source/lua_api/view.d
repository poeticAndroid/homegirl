module lua_api.view;

import std.string;
import std.conv;
import std.algorithm.searching;
import bindbc.lua;

import machine;
import program;
import viewport;

/// view.newscreen(mode, colorbits): view
int view_newscreen(lua_State* L) nothrow
{
  const mode = lua_tointeger(L, 1);
  const colorBits = lua_tointeger(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    lua_pushinteger(L, cast(int) prog.createScreen(cast(ubyte) mode, cast(ubyte) colorBits));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.screenmode(view[, mode, colorbits]): mode, colorbits
int view_screenmode(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const mode = lua_tointeger(L, 2);
  const colorBits = lua_tointeger(L, 3);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    if (set)
      vp.changeMode(cast(ubyte) mode, cast(ubyte) colorBits);
    lua_pushinteger(L, cast(int) vp.mode);
    lua_pushinteger(L, cast(int) vp.pixmap.colorBits);
    return 2;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.new(parentview, left, top, width, height): view
int view_new(lua_State* L) nothrow
{
  const parentId = lua_tointeger(L, 1);
  const left = lua_tonumber(L, 2);
  const top = lua_tonumber(L, 3);
  const width = lua_tonumber(L, 4);
  const height = lua_tonumber(L, 5);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (parentId != 0 && (parentId >= prog.viewports.length || !prog.viewports[cast(uint) parentId]))
      throw new Exception("Invalid viewport!");
    lua_pushinteger(L, cast(int) prog.createViewport(cast(uint) parentId,
        cast(int) left, cast(int) top, cast(uint) width, cast(uint) height));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.active([view]): view
int view_active(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const set = 1 - lua_isnone(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (set)
    {
      Viewport vp;
      if (vpID)
      {
        if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
          throw new Exception("Invalid viewport!");
        vp = prog.viewports[cast(uint) vpID];
      }
      else
      {
        if (!prog.hasPermission(Permissions.manageMainScreen))
          throw new Exception("no permission to manage the main screen!");
        vp = prog.machine.mainScreen;
      }
      prog.activeViewport = vp;
    }
    uint id = cast(uint) countUntil(prog.viewports, prog.activeViewport);
    if (id < 1)
      lua_pushnil(L);
    else
      lua_pushinteger(L, cast(int) id);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.position(view[, left, top]): left, top
int view_position(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const left = lua_tonumber(L, 2);
  const top = lua_tonumber(L, 3);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    if (set)
      vp.move(cast(int) left, cast(int) top);
    lua_pushinteger(L, cast(int) vp.left);
    lua_pushinteger(L, cast(int) vp.top);
    return 2;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.size(view[, width, height]): width, height
int view_size(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const width = lua_tonumber(L, 2);
  const height = lua_tonumber(L, 3);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    if (set)
      vp.resize(cast(uint) width, cast(uint) height);
    lua_pushinteger(L, cast(int) vp.pixmap.width);
    lua_pushinteger(L, cast(int) vp.pixmap.height);
    return 2;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.visible(view[, isvisible]): isvisible
int view_visible(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const visible = lua_toboolean(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    if (set)
      vp.visible = cast(bool) visible;
    lua_pushboolean(L, vp.visible);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.focused(view[, isfocused]): isfocused
int view_focused(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const focused = lua_toboolean(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    if (set)
    {
      if (focused && prog.machine.focusedViewport
          && prog.machine.focusedViewport.program.filename == prog.filename)
      {
        if (!vp.containsViewport(prog.machine.focusedViewport))
          prog.machine.focusViewport(vp);
      }
      else
      {
        if (vp.containsViewport(prog.machine.focusedViewport))
          prog.machine.focusViewport(null);
      }
    }
    lua_pushboolean(L, vp.containsViewport(prog.machine.focusedViewport));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.zindex(view[, index]): index
int view_zindex(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const index = lua_tonumber(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    Viewport par = vp.getParent();
    if (set)
    {
      if (par)
        par.setViewportIndex(vp, cast(int) index);
      else
        prog.machine.setScreenIndex(vp, cast(int) index);
    }
    if (par)
      lua_pushinteger(L, cast(int) par.getViewportIndex(vp));
    else
      lua_pushinteger(L, cast(int) prog.machine.getScreenIndex(vp));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.children(view): views[]
int view_children(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (!prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    Viewport[] entries = vp.getChildren();
    lua_createtable(L, cast(uint) entries.length, 0);
    for (uint i = 0; i < entries.length; i++)
    {
      lua_pushinteger(L, cast(int) prog.addViewport(entries[i]));
      lua_rawseti(L, -2, i + 1);
    }
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.owner(view): programname
int view_owner(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (!prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    lua_pushstring(L, toStringz(vp.program.filename));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.attribute(view, name[, value]): value
int view_attribute(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  const name = to!string(lua_tostring(L, 2));
  const value = to!string(lua_tostring(L, 3));
  const set = 1 - lua_isnoneornil(L, 3);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    Viewport vp;
    if (vpID)
    {
      if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
        throw new Exception("Invalid viewport!");
      vp = prog.viewports[cast(uint) vpID];
    }
    else
    {
      if (set && !prog.hasPermission(Permissions.manageMainScreen))
        throw new Exception("no permission to manage the main screen!");
      vp = prog.machine.mainScreen;
    }
    if (set)
      vp.attributes[name] = value;
    lua_pushstring(L, toStringz(vp.attributes.get(name, null)));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// view.remove(view)
int view_remove(lua_State* L) nothrow
{
  const vpID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (vpID >= prog.viewports.length || !prog.viewports[cast(uint) vpID])
      throw new Exception("Invalid viewport!");
    prog.removeViewport(cast(uint) vpID);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/**
  register viewport functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "view = {}");

  lua_register(lua, "_", &view_newscreen);
  luaL_dostring(lua, "view.newscreen = _");

  lua_register(lua, "_", &view_screenmode);
  luaL_dostring(lua, "view.screenmode = _");

  lua_register(lua, "_", &view_new);
  luaL_dostring(lua, "view.new = _");

  lua_register(lua, "_", &view_active);
  luaL_dostring(lua, "view.active = _");

  lua_register(lua, "_", &view_position);
  luaL_dostring(lua, "view.position = _");

  lua_register(lua, "_", &view_size);
  luaL_dostring(lua, "view.size = _");

  lua_register(lua, "_", &view_visible);
  luaL_dostring(lua, "view.visible = _");

  lua_register(lua, "_", &view_focused);
  luaL_dostring(lua, "view.focused = _");

  lua_register(lua, "_", &view_zindex);
  luaL_dostring(lua, "view.zindex = _");

  lua_register(lua, "_", &view_children);
  luaL_dostring(lua, "view.children = _");

  lua_register(lua, "_", &view_owner);
  luaL_dostring(lua, "view.owner = _");

  lua_register(lua, "_", &view_attribute);
  luaL_dostring(lua, "view.attribute = _");

  lua_register(lua, "_", &view_remove);
  luaL_dostring(lua, "view.remove = _");
}
