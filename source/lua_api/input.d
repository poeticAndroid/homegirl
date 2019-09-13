module lua_api.input;

import std.string;
import std.conv;
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
    const text = to!string(lua_tostring(L, 1));
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      if (set)
        prog.activeViewport.getTextinput().setText(text);
      lua_pushstring(L, toStringz(prog.activeViewport.getTextinput().getText()));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_text);
  luaL_dostring(lua, "input.text = _");

  /// input.selected([text]): text
  extern (C) int input_selected(lua_State* L) @trusted
  {
    const text = to!string(lua_tostring(L, 1));
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      if (set)
        prog.activeViewport.getTextinput().insertText(text);
      lua_pushstring(L, toStringz(prog.activeViewport.getTextinput().getSelectedText()));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_selected);
  luaL_dostring(lua, "input.selected = _");

  /// input.cursor([pos, selected]): pos, selected
  extern (C) int input_cursor(lua_State* L) @trusted
  {
    const pos = lua_tointeger(L, 1);
    const sel = lua_tointeger(L, 2);
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      if (set)
      {
        prog.activeViewport.getTextinput().setPosBytes(cast(uint) pos);
        prog.activeViewport.getTextinput().setSelectedBytes(cast(uint) sel);
      }
      lua_pushinteger(L, prog.activeViewport.getTextinput().posBytes);
      lua_pushinteger(L, prog.activeViewport.getTextinput().selectedBytes);
      return 2;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_cursor);
  luaL_dostring(lua, "input.cursor = _");

  /// input.clearhistory()
  extern (C) int input_clearhistory(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      prog.activeViewport.getTextinput().clearHistory();
      return 0;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_clearhistory);
  luaL_dostring(lua, "input.clearhistory = _");

  /// input.hotkey(): hotkey
  extern (C) int input_hotkey(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      lua_pushstring(L, toStringz("" ~ prog.activeViewport.hotkey));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_hotkey);
  luaL_dostring(lua, "input.hotkey = _");

  /// input.mouse(): x, y, btn
  extern (C) int input_mouse(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      lua_pushinteger(L, prog.activeViewport.mouseX);
      lua_pushinteger(L, prog.activeViewport.mouseY);
      lua_pushinteger(L, prog.activeViewport.mouseBtn);
      return 3;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_mouse);
  luaL_dostring(lua, "input.mouse = _");

  /// input.gamepad([player]): btn
  extern (C) int input_gamepad(lua_State* L) @trusted
  {
    const player = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Exception("No active viewport!");
      lua_pushinteger(L, prog.activeViewport.getGameBtn(cast(ubyte) player));
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_gamepad);
  luaL_dostring(lua, "input.gamepad = _");

  /// input.midi(): byte
  extern (C) int input_midi(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (prog.machine.hasMidi())
        lua_pushinteger(L, prog.machine.getMidi());
      else
        lua_pushnil(L);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &input_midi);
  luaL_dostring(lua, "input.midi = _");
}
