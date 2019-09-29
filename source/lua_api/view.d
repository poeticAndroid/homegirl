module lua_api.view;

import std.string;
import std.conv;
import std.algorithm.searching;
import riverd.lua;
import riverd.lua.types;

import machine;
import program;
import viewport;

/**
  register viewport functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "view = {}");

  /// view.newscreen(mode, colorbits): view
  extern (C) int view_newscreen(lua_State* L) @trusted
  {
    const mode = lua_tointeger(L, 1);
    const colorBits = lua_tointeger(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      lua_pushinteger(L, prog.createScreen(cast(ubyte) mode, cast(ubyte) colorBits));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_newscreen);
  luaL_dostring(lua, "view.newscreen = _");

  /// view.screenmode(view[, mode, colorbits]): mode, colorbits
  extern (C) int view_screenmode(lua_State* L) @trusted
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
      lua_pushinteger(L, vp.mode);
      lua_pushinteger(L, vp.pixmap.colorBits);
      return 2;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_screenmode);
  luaL_dostring(lua, "view.screenmode = _");

  /// view.new(parentview, left, top, width, height): view
  extern (C) int view_new(lua_State* L) @trusted
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
      if (parentId != 0 && (parentId >= prog.viewports.length
          || !prog.viewports[cast(uint) parentId]))
        throw new Exception("Invalid viewport!");
      lua_pushinteger(L, prog.createViewport(cast(uint) parentId, cast(int) left,
          cast(int) top, cast(uint) width, cast(uint) height));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_new);
  luaL_dostring(lua, "view.new = _");

  /// view.active([view]): view
  extern (C) int view_active(lua_State* L) @trusted
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
        lua_pushinteger(L, id);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_active);
  luaL_dostring(lua, "view.active = _");

  /// view.position(view[, left, top]): left, top
  extern (C) int view_position(lua_State* L) @trusted
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
      lua_pushinteger(L, vp.left);
      lua_pushinteger(L, vp.top);
      return 2;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_position);
  luaL_dostring(lua, "view.position = _");

  /// view.size(view[, width, height]): width, height
  extern (C) int view_size(lua_State* L) @trusted
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
      lua_pushinteger(L, vp.pixmap.width);
      lua_pushinteger(L, vp.pixmap.height);
      return 2;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_size);
  luaL_dostring(lua, "view.size = _");

  /// view.visible(view[, isvisible]): isvisible
  extern (C) int view_visible(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_visible);
  luaL_dostring(lua, "view.visible = _");

  /// view.focused(view[, isfocused]): isfocused
  extern (C) int view_focused(lua_State* L) @trusted
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
        if (focused)
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

  lua_register(lua, "_", &view_focused);
  luaL_dostring(lua, "view.focused = _");

  /// view.zindex(view[, index]): index
  extern (C) int view_zindex(lua_State* L) @trusted
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
        lua_pushinteger(L, par.getViewportIndex(vp));
      else
        lua_pushinteger(L, prog.machine.getScreenIndex(vp));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &view_zindex);
  luaL_dostring(lua, "view.zindex = _");

  /// view.children(view): views[]
  extern (C) int view_children(lua_State* L) @trusted
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
        lua_pushinteger(L, prog.addViewport(entries[i]));
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

  lua_register(lua, "_", &view_children);
  luaL_dostring(lua, "view.children = _");

  /// view.owner(view): programname
  extern (C) int view_owner(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_owner);
  luaL_dostring(lua, "view.owner = _");

  /// view.attribute(view, name[, value]): value
  extern (C) int view_attribute(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_attribute);
  luaL_dostring(lua, "view.attribute = _");

  /// view.remove(view)
  extern (C) int view_remove(lua_State* L) @trusted
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

  lua_register(lua, "_", &view_remove);
  luaL_dostring(lua, "view.remove = _");
}
