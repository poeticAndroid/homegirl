module lua_api.image;

import std.string;
import std.conv;
import bindbc.lua;

import machine;
import program;
import pixmap;

/// image.new(width, height, colorbits): img
int image_new(lua_State* L) nothrow
{
  const width = lua_tonumber(L, 1);
  const height = lua_tonumber(L, 2);
  const colorBits = lua_tointeger(L, 3);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    lua_pushinteger(L, cast(int) prog.createPixmap(cast(uint) width,
        cast(uint) height, cast(ubyte) colorBits));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.load(filename[, maxframes]): img[]
int image_load(lua_State* L) nothrow
{
  const filename = to!string(lua_tostring(L, 1));
  auto maxframes = lua_tonumber(L, 2);
  const maxset = 1 - lua_isnoneornil(L, 2);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    if (!maxset)
      maxframes = -1;
    uint[] anim = prog.loadAnimation(prog.actualFile(filename), cast(uint) maxframes);
    lua_createtable(L, cast(uint) anim.length, 0);
    for (uint i = 0; i < anim.length; i++)
    {
      lua_pushinteger(L, cast(int) anim[i]);
      lua_rawseti(L, -2, i + 1);
    }
    return 1;
  }
  catch (Exception err)
  {
    lua_pushnil(L);
    return 1;
  }
}

/// image.save(filename, img[]): success
int image_save(lua_State* L) nothrow
{
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    const filename = toLower(to!string(lua_tostring(L, 1)));
    const anim_len = lua_rawlen(L, 2);

    if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
      throw new Exception("no permission to read other drives!");
    prog.machine.showBusy();
    uint[] anim;
    if (anim_len)
    {
      lua_pushnil(L);
      while (lua_next(L, 2))
      {
        anim ~= cast(uint) lua_tointeger(L, -1);
        lua_pop(L, 1);
      }
    }
    prog.saveAnimation(prog.actualFile(filename), anim);
    lua_pushboolean(L, true);
    return 1;
  }
  catch (Exception err)
  {
    lua_pushboolean(L, false);
    return 1;
  }
}

/// image.size(img): width, height
int image_size(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].width);
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].height);
    return 2;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.colordepth(img):  colorbits
int image_colordepth(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].colorBits);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.duration(img[, milliseconds]): milliseconds
int image_duration(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const duration = lua_tonumber(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);

  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    if (set)
      prog.pixmaps[cast(uint) imgID].duration = cast(uint) duration;
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].duration);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.pixel(img, x, y[, color]): color
int image_pixel(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const x = lua_tonumber(L, 2);
  const y = lua_tonumber(L, 3);
  const c = lua_tonumber(L, 4);
  const set = 1 - lua_isnoneornil(L, 4);

  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    if (set)
      prog.pixmaps[cast(uint) imgID].pset(cast(uint) x, cast(uint) y, cast(ubyte) c);
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].pget(cast(uint) x, cast(uint) y));
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.palette(img, color[, red, green, blue]): red, green, blue
int image_palette(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const c = lua_tonumber(L, 2);
  const r = lua_tonumber(L, 3);
  const g = lua_tonumber(L, 4);
  const b = lua_tonumber(L, 5);
  const set = 1 - lua_isnoneornil(L, 3);

  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    if (set)
      prog.pixmaps[cast(uint) imgID].setColor(cast(uint) c, cast(ubyte) r,
          cast(ubyte) g, cast(ubyte) b);
    uint i = cast(uint)(c * 3) % prog.pixmaps[cast(uint) imgID].palette.length;
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].palette[i++] % 16);
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].palette[i++] % 16);
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].palette[i++] % 16);
    return 3;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.bgcolor(img[, color]): color
int image_bgcolor(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const cindex = lua_tonumber(L, 2);
  const set = 1 - lua_isnoneornil(L, 2);

  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    if (set)
      prog.pixmaps[cast(uint) imgID].setBGColor(cast(ubyte) cindex);
    lua_pushinteger(L, cast(int) prog.pixmaps[cast(uint) imgID].bgColor);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.copymode([mode, masked]): mode, masked
int image_copymode(lua_State* L) nothrow
{
  const mode = lua_tointeger(L, 1);
  const masked = lua_toboolean(L, 2);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
    {
      prog.activeViewport.pixmap.copymode = cast(CopyMode) mode;
      prog.activeViewport.pixmap.copyMasked = cast(bool) masked;
    }
    lua_pushinteger(L, cast(int) prog.activeViewport.pixmap.copymode);
    lua_pushboolean(L, cast(int) prog.activeViewport.pixmap.copyMasked);
    return 2;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.errordiffusion([enabled]): enabled
int image_errordiffusion(lua_State* L) nothrow
{
  const enabled = lua_toboolean(L, 1);
  const set = 1 - lua_isnoneornil(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (set)
      prog.activeViewport.pixmap.errorDiffusion = cast(bool) enabled;
    lua_pushboolean(L, cast(int) prog.activeViewport.pixmap.errorDiffusion);
    return 1;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.tri(img, x1,y1, x2,y2, x3,y3, imgx1,imgy1, imgx2,imgy2, imgx3,imgy3)
int image_tri(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const x1 = lua_tonumber(L, 2);
  const y1 = lua_tonumber(L, 3);
  const x2 = lua_tonumber(L, 4);
  const y2 = lua_tonumber(L, 5);
  const x3 = lua_tonumber(L, 6);
  const y3 = lua_tonumber(L, 7);
  const imgx1 = lua_tonumber(L, 8);
  const imgy1 = lua_tonumber(L, 9);
  const imgx2 = lua_tonumber(L, 10);
  const imgy2 = lua_tonumber(L, 11);
  const imgx3 = lua_tonumber(L, 12);
  const imgy3 = lua_tonumber(L, 13);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    prog.activeViewport.pixmap.copyTriFrom(prog.pixmaps[cast(uint) imgID],
        imgx1, imgy1, imgx2, imgy2, imgx3, imgy3, x1, y1, x2, y2, x3, y3);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.draw(img, x, y, imgx, imgy, width, height[, imgwidth, imgheight])
int image_draw(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  auto x = lua_tonumber(L, 2);
  auto y = lua_tonumber(L, 3);
  auto imgx = lua_tonumber(L, 4);
  auto imgy = lua_tonumber(L, 5);
  auto width = lua_tonumber(L, 6);
  auto height = lua_tonumber(L, 7);
  auto imgwidth = lua_tonumber(L, 8);
  auto imgheight = lua_tonumber(L, 9);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    if (imgwidth == 0)
      imgwidth = width;
    if (imgheight == 0)
      imgheight = height;
    if (width < 0)
    {
      x += width;
      width *= -1;
      imgx += imgwidth;
      imgwidth *= -1;
    }
    if (height < 0)
    {
      y += height;
      height *= -1;
      imgy += imgheight;
      imgheight *= -1;
    }
    float scaleX = imgwidth / width;
    float scaleY = imgheight / height;
    if (scaleX < 0)
      imgx--;
    if (scaleY < 0)
      imgy--;
    prog.activeViewport.pixmap.copyRectFrom(prog.pixmaps[cast(uint) imgID],
        cast(int) imgx, cast(int) imgy, cast(int) x, cast(int) y, cast(uint) width,
        cast(uint) height, scaleX, scaleY);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.copy(img, x, y, imgx, imgy, width, height)
int image_copy(lua_State* L) nothrow
{
  const imgID = lua_tonumber(L, 1);
  const x = lua_tonumber(L, 2);
  const y = lua_tonumber(L, 3);
  const imgx = lua_tonumber(L, 4);
  const imgy = lua_tonumber(L, 5);
  const width = lua_tonumber(L, 6);
  const height = lua_tonumber(L, 7);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    prog.pixmaps[cast(uint) imgID].copyRectFrom(prog.activeViewport.pixmap,
        cast(int) x, cast(int) y, cast(int) imgx, cast(int) imgy,
        cast(uint) width, cast(uint) height);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.usepalette(img)
int image_usepalette(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    prog.activeViewport.pixmap.copyPaletteFrom(prog.pixmaps[cast(uint) imgID]);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.copypalette(img)
int image_copypalette(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    prog.pixmaps[cast(uint) imgID].copyPaletteFrom(prog.activeViewport.pixmap);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.pointer(img, Xoffset, Yoffset)
int image_pointer(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const px = lua_tonumber(L, 2);
  const py = lua_tonumber(L, 3);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.activeViewport)
      throw new Exception("No active viewport!");
    if (imgID >= prog.pixmaps.length)
      throw new Exception("Invalid image!");
    prog.activeViewport.pointer = prog.pixmaps[cast(uint) imgID];
    prog.activeViewport.pointerX = cast(int) px;
    prog.activeViewport.pointerY = cast(int) py;
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.busypointer(img, Xoffset, Yoffset)
int image_busypointer(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  const px = lua_tonumber(L, 2);
  const py = lua_tonumber(L, 3);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (!prog.hasPermission(Permissions.manageMainScreen))
      throw new Exception("no permission to manage the main screen!");
    if (imgID >= prog.pixmaps.length)
      throw new Exception("Invalid image!");
    prog.machine.busyPointer = prog.pixmaps[cast(uint) imgID];
    prog.machine.busyPointerX = cast(int) px;
    prog.machine.busyPointerY = cast(int) py;
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/// image.forget(img)
int image_forget(lua_State* L) nothrow
{
  const imgID = lua_tointeger(L, 1);
  lua_getglobal(L, "__program");
  auto prog = cast(Program*) lua_touserdata(L, -1);
  try
  {
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
      throw new Exception("Invalid image!");
    prog.removePixmap(cast(uint) imgID);
    return 0;
  }
  catch (Exception err)
  {
    luaL_error(L, toStringz(err.msg));
    return 0;
  }
}

/**
  register image functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "image = {}");

  lua_register(lua, "_", &image_new);
  luaL_dostring(lua, "image.new = _");

  lua_register(lua, "_", &image_load);
  luaL_dostring(lua, "image.load = _");

  lua_register(lua, "_", &image_save);
  luaL_dostring(lua, "image.save = _");

  lua_register(lua, "_", &image_size);
  luaL_dostring(lua, "image.size = _");

  lua_register(lua, "_", &image_colordepth);
  luaL_dostring(lua, "image.colordepth = _");

  lua_register(lua, "_", &image_duration);
  luaL_dostring(lua, "image.duration = _");

  lua_register(lua, "_", &image_pixel);
  luaL_dostring(lua, "image.pixel = _");

  lua_register(lua, "_", &image_palette);
  luaL_dostring(lua, "image.palette = _");

  lua_register(lua, "_", &image_bgcolor);
  luaL_dostring(lua, "image.bgcolor = _");

  lua_register(lua, "_", &image_copymode);
  luaL_dostring(lua, "image.copymode = _");

  lua_register(lua, "_", &image_errordiffusion);
  luaL_dostring(lua, "image.errordiffusion = _");

  lua_register(lua, "_", &image_tri);
  luaL_dostring(lua, "image.tri = _");

  lua_register(lua, "_", &image_draw);
  luaL_dostring(lua, "image.draw = _");

  lua_register(lua, "_", &image_copy);
  luaL_dostring(lua, "image.copy = _");

  lua_register(lua, "_", &image_usepalette);
  luaL_dostring(lua, "image.usepalette = _");

  lua_register(lua, "_", &image_copypalette);
  luaL_dostring(lua, "image.copypalette = _");

  lua_register(lua, "_", &image_pointer);
  luaL_dostring(lua, "image.pointer = _");

  lua_register(lua, "_", &image_busypointer);
  luaL_dostring(lua, "image.busypointer = _");

  lua_register(lua, "_", &image_forget);
  luaL_dostring(lua, "image.forget = _");
}
