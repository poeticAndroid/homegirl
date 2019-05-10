module lua_api;

import std.stdio;
import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register some functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;

  //Setup the userdata
  auto prog = cast(Program*) lua_newuserdata(lua, Program.sizeof);
  *prog = program;
  lua_setglobal(lua, "__program");

  extern (C) int panic(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.shutdown();
    writeln("Shit hit the fan!");
    return 0;
  }

  lua_atpanic(lua, &panic);

  /// exit(code)
  extern (C) int exit(lua_State* L) @trusted
  {
    const code = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.shutdown();
    return 0;
  }

  lua_register(lua, "exit", &exit);

  /// print(message)
  extern (C) int print(lua_State* L) @trusted
  {
    const msg = lua_tostring(L, -1);
    writeln("Program says: " ~ fromStringz(msg));
    return 0;
  }

  lua_register(lua, "print", &print);

  /// createscreen(mode, colorbits): id
  extern (C) int createscreen(lua_State* L) @trusted
  {
    const mode = lua_tointeger(L, -2);
    const colorBits = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createScreen(cast(ubyte) mode, cast(ubyte) colorBits));
    return 1;
  }

  lua_register(lua, "createscreen", &createscreen);

  /// createviewport(parent, left, top, width, height): id
  extern (C) int createviewport(lua_State* L) @trusted
  {
    const parentId = lua_tointeger(L, -5);
    const left = lua_tonumber(L, -4);
    const top = lua_tonumber(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createViewport(cast(uint) parentId, cast(int) left,
        cast(int) top, cast(uint) width, cast(uint) height));
    return 1;
  }

  lua_register(lua, "createviewport", &createviewport);

  /// removeviewport(vpID)
  extern (C) int removeviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeViewport(cast(uint) vpId);
    return 0;
  }

  lua_register(lua, "removeviewport", &removeviewport);

  /// createimage(width, height, colorbits): id
  extern (C) int createimage(lua_State* L) @trusted
  {
    const width = lua_tonumber(L, -3);
    const height = lua_tonumber(L, -2);
    const colorBits = lua_tointeger(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createPixmap(cast(uint) width, cast(uint) height, cast(ubyte) colorBits));
    return 1;
  }

  lua_register(lua, "createimage", &createimage);

  /// loadimage(filename): id
  extern (C) int loadimage(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, -1));
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.loadPixmap(cast(string) filename));
    return 1;
  }

  lua_register(lua, "loadimage", &loadimage);

  /// imagewidth(imgID): width
  extern (C) int imagewidth(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.pixmaps[cast(uint) imgId].width);
    return 1;
  }

  lua_register(lua, "imagewidth", &imagewidth);

  /// imageheight(imgID): height
  extern (C) int imageheight(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.pixmaps[cast(uint) imgId].height);
    return 1;
  }

  lua_register(lua, "imageheight", &imageheight);

  /// forgetimage(imgID)
  extern (C) int forgetimage(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removePixmap(cast(uint) imgId);
    return 0;
  }

  lua_register(lua, "forgetimage", &forgetimage);

  /// copyimage(imgID, x, y, imgx, imgy, width, height)
  extern (C) int copyimage(lua_State* L) @trusted
  {
    const imgID = lua_tonumber(L, -7);
    const x = lua_tonumber(L, -6);
    const y = lua_tonumber(L, -5);
    const imgx = lua_tonumber(L, -4);
    const imgy = lua_tonumber(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (!prog.pixmaps[cast(uint) imgID])
    {
      lua_pushstring(L, "Invalid image!");
      lua_error(L);
      return 0;
    }
    prog.pixmaps[cast(uint) imgID].copyFrom(prog.activeViewport.pixmap,
        cast(int) x, cast(int) y, cast(int) imgx, cast(int) imgy,
        cast(uint) width, cast(uint) height);
    return 0;
  }

  lua_register(lua, "copyimage", &copyimage);

  /// drawimage(imgID, x, y, imgx, imgy, width, height)
  extern (C) int drawimage(lua_State* L) @trusted
  {
    const imgID = lua_tointeger(L, -7);
    const x = lua_tonumber(L, -6);
    const y = lua_tonumber(L, -5);
    const imgx = lua_tonumber(L, -4);
    const imgy = lua_tonumber(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (!prog.pixmaps[cast(uint) imgID])
    {
      lua_pushstring(L, "Invalid image!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.pixmap.copyFrom(prog.pixmaps[cast(uint) imgID],
        cast(int) imgx, cast(int) imgy, cast(int) x, cast(int) y,
        cast(uint) width, cast(uint) height);
    return 0;
  }

  lua_register(lua, "drawimage", &drawimage);

  /// copypalette(imgID)
  extern (C) int copypalette(lua_State* L) @trusted
  {
    const imgID = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (!prog.pixmaps[cast(uint) imgID])
    {
      lua_pushstring(L, "Invalid image!");
      lua_error(L);
      return 0;
    }
    prog.pixmaps[cast(uint) imgID].copyPaletteFrom(prog.activeViewport.pixmap);
    return 0;
  }

  lua_register(lua, "copypalette", &copypalette);

  /// usepalette(imgID)
  extern (C) int usepalette(lua_State* L) @trusted
  {
    const imgID = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    if (!prog.pixmaps[cast(uint) imgID])
    {
      lua_pushstring(L, "Invalid image!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.pixmap.copyPaletteFrom(prog.pixmaps[cast(uint) imgID]);
    return 0;
  }

  lua_register(lua, "usepalette", &usepalette);

  /// setcolor(color, red, green, blue)
  extern (C) int setcolor(lua_State* L) @trusted
  {
    const c = lua_tointeger(L, -4);
    const r = lua_tonumber(L, -3);
    const g = lua_tonumber(L, -2);
    const b = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.pixmap.setColor(cast(uint) c, cast(ubyte) r, cast(ubyte) g, cast(ubyte) b);
    return 0;
  }

  lua_register(lua, "setcolor", &setcolor);

  /// getcolor(color, channel): value
  extern (C) int getcolor(lua_State* L) @trusted
  {
    const col = lua_tointeger(L, -2);
    const chan = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    const i = cast(uint)((col * 3 + chan) % prog.activeViewport.pixmap.palette.length);
    lua_pushinteger(L, prog.activeViewport.pixmap.palette[i] % 16);
    return 1;
  }

  lua_register(lua, "getcolor", &getcolor);

  /// fgcolor(index)
  extern (C) int fgcolor(lua_State* L) @trusted
  {
    const cindex = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.fgColor = cast(ubyte) cindex;
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "fgcolor", &fgcolor);

  /// bgcolor(index)
  extern (C) int bgcolor(lua_State* L) @trusted
  {
    const cindex = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.bgColor = cast(ubyte) cindex;
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "bgcolor", &bgcolor);

  /// pget(x, y): color
  extern (C) int pget(lua_State* L) @trusted
  {
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
    lua_pushinteger(L, prog.activeViewport.pixmap.pget(cast(uint) x, cast(uint) y));
    return 1;
  }

  lua_register(lua, "pget", &pget);

  /// plot(x, y)
  extern (C) int plot(lua_State* L) @trusted
  {
    const x = lua_tonumber(L, -2);
    const y = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (prog.activeViewport)
    {
      prog.activeViewport.pixmap.plot(cast(uint) x, cast(uint) y);
    }
    else
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    return 0;
  }

  lua_register(lua, "plot", &plot);

  /// bar(x, y, width, height)
  extern (C) int bar(lua_State* L) @trusted
  {
    const x = lua_tonumber(L, -4);
    const y = lua_tonumber(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    prog.activeViewport.pixmap.bar(cast(int) x, cast(int) y, cast(uint) width, cast(uint) height);
    return 0;
  }

  lua_register(lua, "bar", &bar);

  /// line(x1, y1, x2, y2)
  extern (C) int line(lua_State* L) @trusted
  {
    const x1 = lua_tonumber(L, -4);
    const y1 = lua_tonumber(L, -3);
    const x2 = lua_tonumber(L, -2);
    const y2 = lua_tonumber(L, -1);
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
    }
    prog.activeViewport.pixmap.line(cast(int) x1, cast(int) y1, cast(int) x2, cast(int) y2);
    return 0;
  }

  lua_register(lua, "line", &line);
}
