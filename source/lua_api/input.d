module lua_api.input;

import std.string;
import std.conv;
import bindbc.lua;

import program;

/// input.text([text]): text
int input_text(lua_State* L) nothrow
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
      prog.activeViewport.getTextinput(true).setText(text);
    lua_pushstring(L, toStringz(prog.activeViewport.getTextinput(true).getText()));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.selected([text]): text
int input_selected(lua_State* L) nothrow
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
      prog.activeViewport.getTextinput(true).insertText(text);
    lua_pushstring(L, toStringz(prog.activeViewport.getTextinput(true).getSelectedText()));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.cursor([pos, selected]): pos, selected
int input_cursor(lua_State* L) nothrow
{
  const pos = lua_tonumber(L, 1);
  const sel = lua_tonumber(L, 2);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
    {
      prog.activeViewport.getTextinput(true).setPosBytes(cast(uint) pos);
      prog.activeViewport.getTextinput(true).setSelectedBytes(cast(uint) sel);
    }
    lua_pushinteger(L, cast(int) prog.activeViewport.getTextinput(true).posBytes);
    lua_pushinteger(L, cast(int) prog.activeViewport.getTextinput(true).selectedBytes);
    return 2;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.linesperpage([linesperpage]): linesperpage
int input_linesperpage(lua_State* L) nothrow
{
  const lines = lua_tonumber(L, 1);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.getTextinput(true).linesPerPage = cast(uint) lines;
    lua_pushinteger(L, cast(int) prog.activeViewport.getTextinput(true).linesPerPage);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.clearhistory()
int input_clearhistory(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    prog.activeViewport.getTextinput(true).clearHistory();
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.hotkey(): hotkey
int input_hotkey(lua_State* L) nothrow
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

/// input.mouse(): x, y, btn
int input_mouse(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    lua_pushinteger(L, cast(int) prog.activeViewport.mouseX);
    lua_pushinteger(L, cast(int) prog.activeViewport.mouseY);
    lua_pushinteger(L, cast(int) prog.activeViewport.mouseBtn);
    return 3;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.gamepad([player]): btn
int input_gamepad(lua_State* L) nothrow
{
  const player = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    lua_pushinteger(L, cast(int) prog.activeViewport.getGameBtn(cast(ubyte) player));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.drag(drop, icon)
int input_drag(lua_State* L) nothrow
{
  const drop = to!string(lua_tostring(L, 1));
  const icon = lua_tointeger(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (icon >= prog.pixmaps.length || !prog.pixmaps[cast(uint) icon])
      throw new Exception("Invalid image!");
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (!prog.activeViewport.containsViewport(prog.machine.focusedViewport))
      throw new Exception("viewport is not focused!");
    if (prog.activeViewport.mouseBtn == 0)
      throw new Exception("no mouse buttons pressed!");
    // if (prog.activeViewport.mouseX < 0 || prog.activeViewport.mouseY < 0
    //     || prog.activeViewport.mouseX >= prog.activeViewport.pixmap.width
    //     || prog.activeViewport.mouseY >= prog.activeViewport.pixmap.height)
    //   throw new Exception("mouse is outside viewport!");
    prog.machine.dragObject(drop, prog.pixmaps[cast(uint) icon]);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// input.drop(): drop
int input_drop(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    auto drop = prog.activeViewport.getBasket(true).dispense();
    if (drop)
      lua_pushstring(L, toStringz(drop));
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

/// input.midi(): byte
int input_midi(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (prog.machine.hasMidi())
      lua_pushinteger(L, cast(int) prog.machine.getMidi());
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

/**
  register input functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "input = {}");

  lua_register(lua, "_", &input_text);
  luaL_dostring(lua, "input.text = _");

  lua_register(lua, "_", &input_selected);
  luaL_dostring(lua, "input.selected = _");

  lua_register(lua, "_", &input_cursor);
  luaL_dostring(lua, "input.cursor = _");

  lua_register(lua, "_", &input_linesperpage);
  luaL_dostring(lua, "input.linesperpage = _");

  lua_register(lua, "_", &input_clearhistory);
  luaL_dostring(lua, "input.clearhistory = _");

  lua_register(lua, "_", &input_hotkey);
  luaL_dostring(lua, "input.hotkey = _");

  lua_register(lua, "_", &input_mouse);
  luaL_dostring(lua, "input.mouse = _");

  lua_register(lua, "_", &input_gamepad);
  luaL_dostring(lua, "input.gamepad = _");

  lua_register(lua, "_", &input_drag);
  luaL_dostring(lua, "input.drag = _");

  lua_register(lua, "_", &input_drop);
  luaL_dostring(lua, "input.drop = _");

  lua_register(lua, "_", &input_midi);
  luaL_dostring(lua, "input.midi = _");
}
