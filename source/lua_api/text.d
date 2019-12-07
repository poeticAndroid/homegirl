module lua_api.text;

import std.string;
import std.conv;
import bindbc.lua;

import program;
import pixmap;
import machine;

/// text.loadfont(filename): font
int text_loadfont(lua_State* L) nothrow
{
  auto filename = to!string(lua_tostring(L, 1));
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    filename = prog.resolveResource("fonts", filename, ".gif");
    lua_pushinteger(L, prog.loadFont(prog.actualFile(filename)));
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// text.copymode([mode]): mode
int text_copymode(lua_State* L) nothrow
{
  const mode = lua_tointeger(L, 1);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.pixmap.textCopymode = cast(CopyMode) mode;
    lua_pushinteger(L, prog.activeViewport.pixmap.textCopymode);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// text.draw(text, font, x, y): width, height
int text_draw(lua_State* L) nothrow
{
  const text = to!string(lua_tostring(L, 1));
  const font = lua_tointeger(L, 2);
  const x = lua_tonumber(L, 3);
  const y = lua_tonumber(L, 4);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (font >= prog.fonts.length || !prog.fonts[cast(uint) font])
      throw new Exception("Invalid font!");
    auto o = prog.activeViewport.pixmap.text(text, prog.fonts[cast(uint) font],
        cast(int) x, cast(int) y);
    for (uint i = 0; i < o.length; i++)
      lua_pushinteger(L, o[i]);
    return o.length;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// text.forgetfont(font)
int text_forgetfont(lua_State* L) nothrow
{
  const font = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (font >= prog.fonts.length || !prog.fonts[cast(uint) font])
      throw new Exception("Invalid font!");
    prog.removeFont(cast(uint) font);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/**
  register text functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "text = {}");

  lua_register(lua, "_", &text_loadfont);
  luaL_dostring(lua, "text.loadfont = _");

  lua_register(lua, "_", &text_copymode);
  luaL_dostring(lua, "text.copymode = _");

  lua_register(lua, "_", &text_draw);
  luaL_dostring(lua, "text.draw = _");

  lua_register(lua, "_", &text_forgetfont);
  luaL_dostring(lua, "text.forgetfont = _");
}
