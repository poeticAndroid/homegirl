module lua_api.input;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register input functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "input = {}");

  /// input.getinputtext(): text
  extern (C) int input_getinputtext(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushstring(L, toStringz(prog.activeViewport.getTextinput().getText()));
    return 1;
  }

  lua_register(lua, "_", &input_getinputtext);
  luaL_dostring(lua, "input.getinputtext = _");

  /// input.getinputpos(): position
  extern (C) int input_getinputpos(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushinteger(L, prog.activeViewport.getTextinput().posBytes);
    return 1;
  }

  lua_register(lua, "_", &input_getinputpos);
  luaL_dostring(lua, "input.getinputpos = _");

  /// input.getinputselected(): selection
  extern (C) int input_getinputselected(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushinteger(L, prog.activeViewport.getTextinput().selectedBytes);
    return 1;
  }

  lua_register(lua, "_", &input_getinputselected);
  luaL_dostring(lua, "input.getinputselected = _");

  /// input.setinputtext(text)
  extern (C) int input_setinputtext(lua_State* L) @trusted
  {
    const text = lua_tostring(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.getTextinput().setText(cast(string) fromStringz(text));
    return 0;
  }

  lua_register(lua, "_", &input_setinputtext);
  luaL_dostring(lua, "input.setinputtext = _");

  /// input.setinputpos(pos)
  extern (C) int input_setinputpos(lua_State* L) @trusted
  {
    const pos = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.getTextinput().setPosBytes(cast(uint) pos);
    return 0;
  }

  lua_register(lua, "_", &input_setinputpos);
  luaL_dostring(lua, "input.setinputpos = _");

  /// input.setinputselected(selected)
  extern (C) int input_setinputselected(lua_State* L) @trusted
  {
    const selected = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.getTextinput().setSelectedBytes(cast(uint) selected);
    return 0;
  }

  lua_register(lua, "_", &input_setinputselected);
  luaL_dostring(lua, "input.setinputselected = _");

  /// input.hotkey(): hotkey
  extern (C) int input_hotkey(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushstring(L, toStringz("" ~ prog.activeViewport.hotkey));
    return 1;
  }

  lua_register(lua, "_", &input_hotkey);
  luaL_dostring(lua, "input.hotkey = _");

  /// input.mousex(): x
  extern (C) int input_mousex(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushinteger(L, prog.activeViewport.mouseX);
    return 1;
  }

  lua_register(lua, "_", &input_mousex);
  luaL_dostring(lua, "input.mousex = _");

  /// input.mousey(): y
  extern (C) int input_mousey(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushinteger(L, prog.activeViewport.mouseY);
    return 1;
  }

  lua_register(lua, "_", &input_mousey);
  luaL_dostring(lua, "input.mousey = _");

  /// input.mousebtn(): btn
  extern (C) int input_mousebtn(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushinteger(L, prog.activeViewport.mouseBtn);
    return 1;
  }

  lua_register(lua, "_", &input_mousebtn);
  luaL_dostring(lua, "input.mousebtn = _");

  /// input.gamebtn(player): btn
  extern (C) int input_gamebtn(lua_State* L) @trusted
  {
    const player = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    lua_pushinteger(L, prog.activeViewport.getGameBtn(cast(ubyte) player));
    return 1;
  }

  lua_register(lua, "_", &input_gamebtn);
  luaL_dostring(lua, "input.gamebtn = _");
}
