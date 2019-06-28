module lua_api.text;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;
import pixmap;

/**
  register text functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "text = {}");

  /// text.loadfont(filename): font
  extern (C) int text_loadfont(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, 1));
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      lua_pushinteger(L, prog.loadFont(prog.actualFile(cast(string) filename)));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &text_loadfont);
  luaL_dostring(lua, "text.loadfont = _");

  /// text.copymode([mode]): mode
  extern (C) int text_copymode(lua_State* L) @trusted
  {
    const mode = lua_tointeger(L, 1);
    const set = 1 - lua_isnoneornil(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Throwable("No active viewport!");
      if (set)
        prog.activeViewport.pixmap.textCopymode = cast(CopyMode) mode;
      lua_pushinteger(L, prog.activeViewport.pixmap.textCopymode);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &text_copymode);
  luaL_dostring(lua, "text.copymode = _");

  /// text.draw(text, font, x, y): width
  extern (C) int text_draw(lua_State* L) @trusted
  {
    const text = lua_tostring(L, 1);
    const font = lua_tointeger(L, 2);
    const x = lua_tonumber(L, 3);
    const y = lua_tonumber(L, 4);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.activeViewport)
        throw new Throwable("No active viewport!");
      if (!prog.fonts[cast(uint) font])
        throw new Throwable("Invalid font!");
      prog.activeViewport.pixmap.text(cast(string) fromStringz(text),
          prog.fonts[cast(uint) font], cast(int) x, cast(int) y);
      return 0;
    }
    catch (Exception err)
    {
      lua_pushstring(L, toStringz(err.msg));
      lua_error(L);
      return 0;
    }
  }

  lua_register(lua, "_", &text_draw);
  luaL_dostring(lua, "text.draw = _");

  /// text.forgetfont(font)
  extern (C) int text_forgetfont(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeFont(cast(uint) imgId);
    return 0;
  }

  lua_register(lua, "_", &text_forgetfont);
  luaL_dostring(lua, "text.forgetfont = _");
}
