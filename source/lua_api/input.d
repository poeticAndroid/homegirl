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

  /// input.text([text]): text
  extern (C) int input_text(lua_State* L) @trusted
  {
    const text = lua_tostring(L, 1);
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      prog.activeViewport.getTextinput().setText(cast(string) fromStringz(text));
    lua_pushstring(L, toStringz(prog.activeViewport.getTextinput().getText()));
    return 1;
  }

  lua_register(lua, "_", &input_text);
  luaL_dostring(lua, "input.text = _");

  /// input.cursor([pos]): pos
  extern (C) int input_cursor(lua_State* L) @trusted
  {
    const pos = lua_tointeger(L, 1);
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      prog.activeViewport.getTextinput().setPosBytes(cast(uint) pos);
    lua_pushinteger(L, prog.activeViewport.getTextinput().posBytes);
    return 1;
  }

  lua_register(lua, "_", &input_cursor);
  luaL_dostring(lua, "input.cursor = _");

  /// input.selected([selected]): selected
  extern (C) int input_selected(lua_State* L) @trusted
  {
    const selected = lua_tointeger(L, 1);
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (set)
      prog.activeViewport.getTextinput().setSelectedBytes(cast(uint) selected);
    lua_pushinteger(L, prog.activeViewport.getTextinput().selectedBytes);
    return 1;
  }

  lua_register(lua, "_", &input_selected);
  luaL_dostring(lua, "input.selected = _");

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

  /// input.gamebtn([player]): btn
  extern (C) int input_gamebtn(lua_State* L) @trusted
  {
    const player = lua_tointeger(L, 1);
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
