module lua_api.text;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register text functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "text = {}");

  /// text.loadfont(filename): id
  extern (C) int text_loadfont(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, -1));
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.loadFont(cast(string) filename));
    return 1;
  }

  lua_register(lua, "_", &text_loadfont);
  luaL_dostring(lua, "text.loadfont = _");

  /// text.forgetfont(imgID)
  extern (C) int text_forgetfont(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeFont(cast(uint) imgId);
    return 0;
  }

  lua_register(lua, "_", &text_forgetfont);
  luaL_dostring(lua, "text.forgetfont = _");

  /// text.text(text, font, x, y): width
  extern (C) int text_text(lua_State* L) @trusted
  {
    const text = lua_tostring(L, -4);
    const font = lua_tointeger(L, -3);
    const x = lua_tonumber(L, -2);
    const y = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    if (!prog.fonts[cast(uint) font])
    {
      lua_pushstring(L, "Invalid font!");
      lua_error(L);
    }
    prog.activeViewport.pixmap.text(cast(string) fromStringz(text),
        prog.fonts[cast(uint) font], cast(int) x, cast(int) y);
    return 0;
  }

  lua_register(lua, "_", &text_text);
  luaL_dostring(lua, "text.text = _");
}
