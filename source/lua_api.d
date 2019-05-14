module lua_api;

import std.stdio;
import std.string;
import riverd.lua;
import riverd.lua.types;

import program;
import viewport;
import pixmap;

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

  /// exec(filename)
  extern (C) int exec(lua_State* L) @trusted
  {
    const filename = lua_tostring(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.startProgram(cast(string) fromStringz(filename));
    return 0;
  }

  lua_register(lua, "exec", &exec);

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

  /// changescreenmode(screenID, mode, colorbits)
  extern (C) int changescreenmode(lua_State* L) @trusted
  {
    const screenId = lua_tointeger(L, -3);
    const mode = lua_tointeger(L, -2);
    const colorBits = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    Viewport vp = prog.machine.mainScreen;
    if (screenId > 0)
    {
      vp = prog.viewports[cast(uint) screenId];
    }
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.changeMode(cast(ubyte) mode, cast(ubyte) colorBits);
    return 0;
  }

  lua_register(lua, "changescreenmode", &changescreenmode);

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

  /// activeviewport(vpID)
  extern (C) int activeviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport = vp;
    return 0;
  }

  lua_register(lua, "activeviewport", &activeviewport);

  /// moveviewport(vpID, left, top)
  extern (C) int moveviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -3);
    const left = lua_tonumber(L, -2);
    const top = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.move(cast(int) left, cast(int) top);
    return 0;
  }

  lua_register(lua, "moveviewport", &moveviewport);

  /// resizeviewport(vpID, left, top)
  extern (C) int resizeviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -3);
    const width = lua_tonumber(L, -2);
    const height = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.resize(cast(uint) width, cast(uint) height);
    return 0;
  }

  lua_register(lua, "resizeviewport", &resizeviewport);

  /// showviewport(vpID, visible)
  extern (C) int showviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -2);
    const visible = lua_toboolean(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    auto vp = prog.viewports[cast(uint) vpId];
    if (!vp)
    {
      lua_pushstring(L, "Invalid viewport!");
      lua_error(L);
      return 0;
    }
    vp.visible = cast(bool) visible;
    return 0;
  }

  lua_register(lua, "showviewport", &showviewport);

  /// viewportleft(vpID): left
  extern (C) int viewportleft(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].left);
    return 1;
  }

  lua_register(lua, "viewportleft", &viewportleft);

  /// viewporttop(vpID): top
  extern (C) int viewporttop(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].top);
    return 1;
  }

  lua_register(lua, "viewporttop", &viewporttop);

  /// viewportwidth(vpID): width
  extern (C) int viewportwidth(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].pixmap.width);
    return 1;
  }

  lua_register(lua, "viewportwidth", &viewportwidth);

  /// viewportheight(vpID): height
  extern (C) int viewportheight(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.viewports[cast(uint) vpId].pixmap.height);
    return 1;
  }

  lua_register(lua, "viewportheight", &viewportheight);

  /// viewportfocused(vpID): focused
  extern (C) int viewportfocused(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushboolean(L,
        prog.viewports[cast(uint) vpId].containsViewport(prog.machine.focusedViewport));
    return 1;
  }

  lua_register(lua, "viewportfocused", &viewportfocused);

  /// focusviewport(vpID)
  extern (C) int focusviewport(lua_State* L) @trusted
  {
    const vpId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.focusViewport(prog.viewports[cast(uint) vpId]);
    return 1;
  }

  lua_register(lua, "focusviewport", &focusviewport);

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

  /// mousex(): x
  extern (C) int mousex(lua_State* L) @trusted
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

  lua_register(lua, "mousex", &mousex);

  /// mousey(): y
  extern (C) int mousey(lua_State* L) @trusted
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

  lua_register(lua, "mousey", &mousey);

  /// mousebtn(): btn
  extern (C) int mousebtn(lua_State* L) @trusted
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

  lua_register(lua, "mousebtn", &mousebtn);

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

  /// loadanimation(filename): id
  extern (C) int loadanimation(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, -1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    uint[] anim = prog.loadAnimation(cast(string) filename);
    lua_createtable(L, cast(uint) anim.length, 0);
    for (uint i = 0; i < anim.length; i++)
    {
      lua_pushinteger(L, anim[i]);
      lua_rawseti(L, -2, i + 1);
    }
    return 1;
  }

  lua_register(lua, "loadanimation", &loadanimation);

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

  /// imageduration(imgID): height
  extern (C) int imageduration(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.pixmaps[cast(uint) imgId].duration);
    return 1;
  }

  lua_register(lua, "imageduration", &imageduration);

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

  /// copymode(mode)
  extern (C) int copymode(lua_State* L) @trusted
  {
    const mode = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (!prog.activeViewport)
    {
      lua_pushstring(L, "No active viewport!");
      lua_error(L);
      return 0;
    }
    prog.activeViewport.pixmap.copymode = cast(CopyMode) mode;
    return 0;
  }

  lua_register(lua, "copymode", &copymode);

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
    if (imgID >= prog.pixmaps.length || !prog.pixmaps[cast(uint) imgID])
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

  /// loadfont(filename): id
  extern (C) int loadfont(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, -1));
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.loadFont(cast(string) filename));
    return 1;
  }

  lua_register(lua, "loadfont", &loadfont);

  /// forgetfont(imgID)
  extern (C) int forgetfont(lua_State* L) @trusted
  {
    const imgId = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeFont(cast(uint) imgId);
    return 0;
  }

  lua_register(lua, "forgetfont", &forgetfont);

  /// text(text, font, x, y): width
  extern (C) int text(lua_State* L) @trusted
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

  lua_register(lua, "text", &text);
}
