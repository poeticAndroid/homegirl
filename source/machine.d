module machine;

import std.string;
import std.format;
import std.math;
import std.algorithm.searching;
import std.algorithm.mutation;
import std.path;
import std.file;
import std.conv;
import std.process;
import std.algorithm;
import bindbc.sdl;

version (Win64)
{
  import minuit;
}

import viewport;
import screen;
import program;
import texteditor;
import soundchip;
import pixmap;
import image_loader;
import network;

const VERSION = "0.9.2"; /// version of the software

/**
  Class representing "the machine"!
*/
class Machine
{
  SDL_Window* win; /// the main window
  bool running = true; /// is the machine running?
  bool fullscreen = false; /// is the machine running in full screen?
  Screen[] screens; /// all the screens
  Screen mainScreen; /// the first screen ever created
  Viewport focusedViewport; /// the viewport that has focus
  bool widescreen; /// whether to do 16:9 or 4:3 aspect ratio
  Program[] programs; /// all the programs currently running on the machine
  ubyte[uint][2] gameBindings; /// keyboard bindings to game input
  bool hasGamepad = false; /// has a gamepad been used?
  uint cursorBlank = 0; /// when to hide the cursor if idle
  SoundChip audio; /// audio output
  Network net; /// networking system
  string[string] drives; /// a table of all the console drives and their corresponding host folder
  uint[string] perms; /// a table of all the console drives and their corresponding permissions
  uint[string] reqPerms; /// a table of all the console drives and their corresponding requested permissions
  string[string] env; /// environment variables
  Pixmap[][string] fonts; /// fonts loaded
  string configFile; /// path of the config file
  Pixmap[] draggedIcons; /// icons representing the objects currently being dragged
  string[] draggedObjects; /// objects currently being dragged

  /**
    Create a new machine
  */
  this()
  {
    if (loadSDL() != sdlSupport)
      throw new Exception("SDL2 2.0.8 is required!");
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK) != 0)
      throw new Exception(format("SDL_Init Error: %s", SDL_GetError()));

    this.initWindow();
    this.audio = new SoundChip();
    this.initMidi();
    this.env["ENGINE"] = "Homegirl";
    this.env["ENGINE_VERSION"] = VERSION;
  }

  /**
    advance the machine one step
  */
  void step()
  {
    // track mouse position
    this.trackMouse();

    // Event loop
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      // writeln(event.type);
      switch (event.type)
      {
      case SDL_QUIT:
        running = false;
        break;
      case SDL_MOUSEMOTION:
        this.cursorBlank = SDL_GetTicks() + 8192;
        break;
      case SDL_MOUSEWHEEL:
        if (this.focusedViewport && this.focusedViewport.getTextinput())
        {
          auto te = this.focusedViewport.getTextinput();
          if (event.wheel.y < 0)
          {
            newInput = true;
            te.down();
            te.down();
            te.down();
          }
          else if (event.wheel.y > 0)
          {
            newInput = true;
            te.up();
            te.up();
            te.up();
          }
        }
        break;
      case SDL_TEXTINPUT:
        this.newInput = true;
        if (this.focusedViewport && this.focusedViewport.getTextinput())
          this.handleTextInput(this.focusedViewport.getTextinput(),
              to!string(cast(char*) event.text.text));
        break;
      case SDL_KEYDOWN:
        this.newInput = true;
        if (this.focusedViewport)
        {
          if ((SDL_GetModState() & KMOD_CTRL && event.key.keysym.sym < 128)
              || event.key.keysym.sym == 9 || event.key.keysym.sym == 27)
            this.focusedViewport.setHotkey(cast(char) event.key.keysym.sym);
        }

        this.handleTextEdit(event.key.keysym.sym);
        switch (event.key.keysym.sym)
        {
        case SDLK_F7:
          SDL_SetWindowSize(this.win, (640 + 32) * scale, ((this.oldAspect ? 480 : 360) + 18)
              * scale);
          SDL_SetWindowPosition(this.win, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
          break;
        case SDLK_F8:
          this.audio.sync();
          break;
        case SDLK_F11:
          this.toggleFullscren();
          break;
        case SDLK_F12:
          version (Windows)
          {
            spawnShell("start " ~ escapeWindowsArgument(std.path.dirName(this.configFile)));
          }
          else version (OSX)
          {
            spawnShell("open " ~ escapeShellFileName(std.path.dirName(this.configFile)));
          }
          else
          {
            spawnShell("xdg-open " ~ escapeShellFileName(std.path.dirName(this.configFile)));
          }
          break;
        default:
        }
        break;
      case SDL_KEYUP:
        this.newInput = true;
        break;
      default:
        // writeln("event ", event.type);
      }
    }
    // read game controller
    this.handleGameCtrl();
    // read midi input
    this.handleMidi();

    // advance the programs
    uint runningPrograms = 0;
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program program = this.programs[i];
      if (program)
      {
        this.net.referer = program.url;
        runningPrograms++;
        if (!program.running)
          this.shutdownProgram(program);
        else
        {
          if (program.nextStep == 0)
            this.newInput = true;
          if ((program.stepInterval < 0 && newInput) || (program.stepInterval < -1
              && newStir) || (program.stepInterval >= 0 && program.nextStep <= SDL_GetTicks()))
            program.step(SDL_GetTicks());
        }
      }
    }
    this.newInput = false;
    this.newStir = false;

    if (runningPrograms == 0)
    {
      if (!this.nextBootup)
      {
        this.nextBootup = SDL_GetTicks() + 512;
        this.bootupState = 1;
      }
      switch (this.bootupState)
      {
      case 1:
        SDL_SetRenderDrawColor(this.ren, 0, 0, 0, 255);
        break;
      case 2:
        SDL_SetRenderDrawColor(this.ren, 85, 85, 85, 255);
        break;
      case 3:
        SDL_SetRenderDrawColor(this.ren, 170, 170, 170, 255);
        break;
      case 4:
        SDL_SetRenderDrawColor(this.ren, 255, 255, 255, 255);
        break;
      case 5:
        this.startProgram("SYS:startup.lua");
        this.bootupState = 0;
        break;
      default:
        this.running = false;
      }
      SDL_RenderClear(this.ren);
      if (this.bootupState && SDL_GetTicks() > this.nextBootup)
      {
        this.bootupState++;
        this.nextBootup += 512;
      }
    }
    this.audio.step(SDL_GetTicks());
    this.drawScreens();
  }

  /**
    shutdown the machine
  */
  void shutdown()
  {
    this.running = false;
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program program = this.programs[i];
      if (program)
        this.shutdownProgram(program);
    }
    this.net.shutdown();
    version (Win64)
    {
      foreach (MnInput input; this.midiDevs)
        input.close();
    }
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
  }

  /**
    start a program
  */
  Program startProgram(string filename, string[] args = [], string cwd = null)
  {
    Program program = new Program(this, filename, args, cwd);
    if (this.net.isUrl(this.drives[program.drive]))
      program.url = this.drives[program.drive] ~ program.filename[program.drive.length + 1 .. $];
    this.programs ~= program;
    return program;
  }

  /**
    shut down a program
  */
  void shutdownProgram(Program program)
  {
    auto i = countUntil(this.programs, program);
    if (i < 0)
      return;
    if (program.running)
      program.shutdown(-1);
    program.shutdown(-1);
    this.programs[i] = null;
  }

  /**
    kill all programs matching programname
  */
  uint killAll(string programname)
  {
    uint count = 0;
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program prog = this.programs[i];
      if (prog && prog.filename == programname)
      {
        prog.shutdown(-1);
        count++;
      }
    }
    return count;
  }

  /**
    create new screen
  */
  Screen createScreen(ubyte mode, ubyte colorBits)
  {
    Screen.widescreen = this.widescreen;
    Screen screen = new Screen(mode, colorBits);
    this.screens ~= screen;
    if (this.mainScreen)
    {
      screen.pointer = this.mainScreen.pointer;
      screen.pointerX = this.mainScreen.pointerX;
      screen.pointerY = this.mainScreen.pointerY;
    }
    else
    {
      this.mainScreen = screen;
      screen.defaultPointer();
    }
    return screen;
  }

  /**
    remove a screen
  */
  void removeScreen(Viewport screen)
  {
    auto i = countUntil(this.screens, screen);
    if (i < 0)
      return;
    if (screen != this.mainScreen)
    {
      this.screens = this.screens.remove(i);
      screen.detach();
    }
  }

  /**
    get z-index of a screen
  */
  int getScreenIndex(Viewport screen)
  {
    return cast(int) countUntil(this.screens, screen);
  }

  /**
    set z-index of a screen
  */
  void setScreenIndex(Viewport screen, int index)
  {
    auto i = countUntil(this.screens, screen);
    if (i < 0)
      return;
    while (index < 0)
      index += this.screens.length;
    if (index >= this.screens.length)
      index = cast(int) this.screens.length - 1;
    this.screens = this.screens.remove(i);
    this.screens = this.screens[0 .. index] ~ [cast(Screen) screen] ~ this.screens[index .. $];
  }

  /**
    make a viewport focused
  */
  void focusViewport(Viewport vp)
  {
    if (this.focusedViewport != vp)
    {
      if (this.focusedViewport)
      {
        this.focusedViewport.setHotkey(0);
        this.focusedViewport.setMouseBtn(0);
        this.focusedViewport.setGameBtn(0, 1);
        this.focusedViewport.setGameBtn(0, 2);
      }
      this.focusedViewport = vp;
    }
  }

  /**
    toggle fullscreen on/off
  */
  void toggleFullscren()
  {
    this.fullscreen = !this.fullscreen;
    if (this.fullscreen)
    {
      SDL_SetWindowFullscreen(this.win, SDL_WINDOW_FULLSCREEN_DESKTOP);
    }
    else
    {
      SDL_SetWindowFullscreen(this.win, 0);
    }
    this.initWindow();
  }

  /**
    bind key to game input
  */
  void bindGameBtn(uint player, uint scancode, ubyte btn)
  {
    this.gameBindings[player][scancode] = btn;
  }

  /**
    mount a local drive
  */
  void mountLocalDrive(string name, string path, uint perms = 0)
  {
    if (this.net.isUrl(path))
      throw new Exception("Invalid path!");
    if (!isValidPath(path))
      throw new Exception("Invalid path!");
    name = toLower(this.getDrive(name ~ ":", ""));
    path = absolutePath(path);
    if (this.drives.get(name, null))
      throw new Exception("Drive '" ~ name ~ "' already mounted!");
    try
    {
      if (!exists(path))
        mkdirRecurse(path);
    }
    catch (Exception err)
    {
    }
    if (path[$ - 1 .. $] != dirSeparator)
      path ~= dirSeparator;
    this.drives[name] = path;
    this.perms[name] = perms;
  }

  /**
    mount a remote drive
  */
  void mountRemoteDrive(string name, string url, uint perms = 0)
  {
    if (!this.net.isUrl(url))
      throw new Exception("Invalid URL!");
    name = toLower(this.getDrive(name ~ ":", ""));
    if (url[$ - 1 .. $] != "/")
      url ~= "/";
    if (this.drives.get(name, null))
      throw new Exception("Drive '" ~ name ~ "' already mounted!");
    if (!exists(this.net.get(url)))
      throw new Exception("Could not mount drive '" ~ name ~ "'!");
    this.drives[name] = url;
    this.perms[name] = perms;
  }

  /**
    unmount a drive
  */
  void unmountDrive(string name, bool force = false)
  {
    name = toLower(this.getDrive(name ~ ":", ""));
    if (!this.drives.get(name, null))
      return;
    uint inUse = 0;
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program program = this.programs[i];
      if (program && this.getDrive(program.filename, "") == name)
      {
        if (force)
          program.shutdown(-1);
        else
          inUse++;
      }
    }
    if (inUse)
      throw new Exception("Drive '" ~ name ~ "' is in use!");
    this.drives.remove(name);
    this.perms.remove(name);
    this.reqPerms.remove(name);
  }

  /**
    load a font
  */
  Pixmap[] getFont(string filename)
  {
    if (!this.fonts.get(filename, null))
      this.fonts[filename] = image_loader.loadAnimation(filename);
    return this.fonts[filename];
  }

  /**
    resolve console path to host path
  */
  string actualPath(string consolePath, bool dir = false)
  {
    string actual;
    string drive = this.getDrive(consolePath, "");
    if (!drive)
      throw new Exception("Path is not absolute!");
    if (!this.drives.get(drive, null))
      throw new Exception("Drive '" ~ drive ~ "' does not exist!");
    string path = consolePath[drive.length + 1 .. $];
    if (this.net.isUrl(this.drives[drive]))
    {
      if (dir)
        actual = this.net.get(this.drives[drive] ~ path)[0 .. $ - 6] ~ ".~dir/";
      else
        actual = this.net.get(this.drives[drive] ~ path);
    }
    else
      actual = buildNormalizedPath(this.drives[drive], path) ~ (dir ? "/" : "");
    if (!exists(actual) && path != toLower(path))
      return this.actualPath(toLower(consolePath), dir);
    return actual;
  }

  /**
    sync console path to network
  */
  bool syncPath(string consolePath, string rename = null)
  {
    string drive2, path2;
    string drive = this.getDrive(consolePath, "");
    if (rename)
      drive2 = this.getDrive(rename, "");
    if (!drive)
      throw new Exception("Path is not absolute!");
    if (!this.drives.get(drive, null))
      throw new Exception("Drive '" ~ drive ~ "' does not exist!");
    string path = toLower(consolePath[drive.length + 1 .. $]);
    if (rename)
      path2 = toLower(rename[drive2.length + 1 .. $]);
    if (this.net.isUrl(this.drives[drive]))
      return this.net.sync(this.drives[drive] ~ path, rename ? this.drives[drive2] ~ path2 : null);
    return true;
  }

  /**
    post to console path 
  */
  ubyte[] postPath(string consolePath, string payload, string type)
  {
    string drive = this.getDrive(consolePath, "");
    if (!drive)
      throw new Exception("Path is not absolute!");
    if (!this.drives.get(drive, null))
      throw new Exception("Drive '" ~ drive ~ "' does not exist!");
    string path = consolePath[drive.length + 1 .. $];
    if (this.net.isUrl(this.drives[drive]))
      return this.net.post(this.drives[drive] ~ path, payload, type);
    return null;
  }

  /**
    get drive name of path
  */
  string getDrive(string path, string end = ":")
  {
    const i = countUntil(path, ":");
    if (i <= 0)
      return null;
    else
      return toLower(path[0 .. i]) ~ end;
  }

  /**
    get parent of path
  */
  string dirName(string path)
  {
    if (path[$ - 1 .. $] == "/")
      path = path[0 .. $ - 1];
    auto i = path.length;
    while (i >= 1 && path[i - 1 .. i] != "/" && path[i - 1 .. i] != ":")
      i--;
    return path[0 .. i];
  }

  /**
    get basename of path
  */
  string baseName(string path)
  {
    if (path[$ - 1 .. $] == "/")
      path = path[0 .. $ - 1];
    auto i = path.length;
    while (i >= 1 && path[i - 1 .. i] != "/" && path[i - 1 .. i] != ":")
      i--;
    return path[i .. $];
  }

  /**
    generate lua code for filepath vars
  */
  string luaFilepathVars(string path)
  {
    string code = "local _DRIVE = \"" ~ this.getDrive(path) ~ "\" ";
    code ~= "local _DIR   = \"" ~ this.dirName(path) ~ "\" ";
    code ~= "local _FILE  = \"" ~ this.baseName(path) ~ "\" ";
    return code;
  }

  /**
    get a byte of midi data
  */
  ubyte getMidi()
  {
    this.midiTimeout = SDL_GetTicks() + 1024;
    if (!this.midiData.length)
      return 0;
    ubyte byt = this.midiData[0];
    this.midiData = this.midiData.remove(0);
    return byt;
  }

  /**
    check if there is pending midi data
  */
  bool hasMidi()
  {
    return this.midiData.length > 0;
  }

  /**
    grab an object to drag around
  */
  void dragObject(string obj, Pixmap icon)
  {
    this.draggedObjects ~= obj;
    this.draggedIcons ~= icon;
  }

  // === _privates === //
  private SDL_Renderer* ren; /// the main renderer
  private auto rect = new SDL_Rect();
  private auto rect2 = new SDL_Rect();
  private int lastmx = 0;
  private int lastmy = 0;
  private uint lastmb = 0;
  private ubyte[] gameBtns;
  private ulong lastgmb = 0;
  version (Win64)
  {
    private MnInput[] midiDevs;
  }
  private ubyte[] midiData;
  private uint midiTimeout;
  private uint scale;
  private uint bootupState = 5;
  private uint nextBootup;
  private bool newInput;
  private bool newStir;
  private bool oldAspect;
  private Pixmap pointer;
  private int pointerX;
  private int pointerY;

  private void initWindow()
  {
    int x = SDL_WINDOWPOS_CENTERED;
    int y = SDL_WINDOWPOS_CENTERED;
    int w = 640 + 48;
    int h = 360 + 48;
    SDL_WindowFlags flags = SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI;
    if (this.win)
    {
      flags = SDL_GetWindowFlags(this.win);
      if (flags & SDL_WINDOW_FULLSCREEN_DESKTOP)
        SDL_SetWindowFullscreen(this.win, 0);
      if (flags & SDL_WINDOW_MAXIMIZED)
        SDL_RestoreWindow(this.win);
      SDL_GetWindowPosition(this.win, &x, &y);
      SDL_GetWindowSize(this.win, &w, &h);
      this.destroyWindow();
    }
    // Create a window
    this.win = SDL_CreateWindow(toStringz("Homegirl " ~ VERSION), x, y, w, h, flags);
    if (win == null)
    {
      SDL_Quit();
      throw new Exception(format("SDL_CreateWindow Error: %s", SDL_GetError()));
    }
    SDL_SetWindowIcon(this.win, SDL_LoadBMP("homegirl.bmp"));
    this.ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren == null)
    {
      SDL_DestroyWindow(win);
      SDL_Quit();
      throw new Exception(format("SDL_CreateRenderer Error: %s", SDL_GetError()));
    }
    SDL_StartTextInput();
    // SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
  }

  private void destroyWindow()
  {
    for (uint i = 0; i < this.screens.length; i++)
      this.screens[i].pixmap.destroyTexture();
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
  }

  private void trackMouse()
  {
    const width = 640;
    uint height = 360;
    if (this.oldAspect)
      height = 480;
    int dx;
    int dy;
    SDL_GetWindowSize(this.win, &dx, &dy);
    if (dx < width)
    {
      dx = width;
      SDL_SetWindowSize(this.win, dx, dy);
    }
    if (dy < height)
    {
      dy = height;
      SDL_SetWindowSize(this.win, dx, dy);
    }
    uint scale = cast(int) fmax(1.0, floor(fmin(dx / width, dy / height)));
    dx = (dx - width * scale) / 2;
    dy = (dy - height * scale) / 2;
    int mx;
    int my;
    ubyte mb = cast(ubyte) SDL_GetMouseState(&mx, &my);
    mb = (mb / 2) + (mb % 2);
    if (mx > dx)
      mx = (mx - dx) / scale;
    else
      mx = ((dx - mx) / scale) * -1;
    if (my > dy)
      my = (my - dy) / scale;
    else
      my = ((dy - my) / scale) * -1;

    Viewport vp;
    bool validFocus = false;
    for (uint i = 0; i < this.screens.length; i++)
    {
      auto screen = this.screens[i];
      Viewport _vp = screen.setMouseXY(mx / screen.pixelWidth, (my - screen.top) / screen
          .pixelHeight);
      if (_vp)
        vp = _vp;
      if (screen.containsViewport(this.focusedViewport))
        validFocus = validFocus || true;
    }
    if (SDL_GetTicks() > this.cursorBlank)
    {
      SDL_ShowCursor(SDL_DISABLE);
      this.pointer = null;
    }
    else
    {
      Viewport pvp = vp;
      while (pvp && !pvp.pointer)
        pvp = pvp.getParent();
      if (pvp)
      {
        this.pointer = pvp.pointer;
        this.pointerX = pvp.pointerX;
        this.pointerY = pvp.pointerY;
        SDL_ShowCursor(SDL_DISABLE);
      }
      else
      {
        SDL_ShowCursor(SDL_ENABLE);
      }
    }
    if (mb == 0)
    {
      if (vp && vp.getBasket())
        vp.getBasket().deposit(this.draggedObjects);
      this.draggedObjects = [];
      this.draggedIcons = [];
    }
    if (this.draggedObjects.length && this.focusedViewport)
      this.focusedViewport.setMouseBtn(0);
    if (this.lastmb == 0 && mb == 1)
      this.focusViewport(vp);
    if (!validFocus && this.screens.length)
      this.focusViewport(this.screens[$ - 1].getFrontBranch());
    if (this.focusedViewport && !this.focusedViewport.isVisible())
      this.focusViewport(this.focusedViewport.getParent());
    if (this.lastmb != mb)
    {
      this.newInput = true;
      this.lastmb = mb;
      if (this.focusedViewport)
        this.focusedViewport.setMouseBtn(mb);
    }
    if (this.lastmx != mx || this.lastmy != my)
    {
      this.newStir = true;
      this.lastmx = mx;
      this.lastmy = my;
      if (mb)
      {
        this.newInput = true;
      }
    }
  }

  private void drawScreens()
  {
    const width = 640;
    uint height = 360;
    if (this.oldAspect)
      height = 480;
    int dx;
    int dy;
    SDL_GetWindowSize(this.win, &dx, &dy);
    if (dx < width)
    {
      dx = width;
      SDL_SetWindowSize(this.win, dx, dy);
    }
    if (dy < height)
    {
      dy = height;
      SDL_SetWindowSize(this.win, dx, dy);
    }
    scale = cast(int) fmax(1.0, floor(fmin(dx / width, dy / height)));
    dx = (dx - width * scale) / 2;
    dy = (dy - height * scale) / 2;
    int highest = 1024;

    bool oldAspect = false;
    if (this.screens.length && this.screens[$ - 1].pixmap.height
        * this.screens[$ - 1].pixelHeight > 400)
      oldAspect = true;
    for (uint i = 0; i < this.screens.length; i++)
    {
      auto screen = this.screens[i];
      if (screen.top < 0)
        screen.top = 0;
      // if (screen.top > height)
      //   screen.top = height;
      auto pixmap = screen.pixmap;
      int nextPos = height;
      if (this.screens.length > i + 1)
        nextPos = this.screens[i + 1].top;
      if (screen.top >= nextPos)
        continue;

      SDL_SetRenderDrawColor(ren, pixmap.palette[0], pixmap.palette[1], pixmap.palette[2], 255);
      if (screen.top <= highest)
      {
        SDL_RenderClear(ren);
        highest = screen.top;
      }
      else
      {
        this.rect.x = 0;
        this.rect.y = dy + screen.top * scale - 5 * scale;
        SDL_GetWindowSize(this.win, &this.rect.w, &this.rect.h);
        SDL_RenderFillRect(ren, rect);
      }
      rect.x = 0;
      rect.y = 0;
      rect.w = pixmap.width;
      rect.h = pixmap.height; // - screen.top / screen.pixelHeight;
      rect2.x = dx;
      rect2.y = dy + screen.top * scale;
      rect2.w = rect.w * screen.pixelWidth * scale;
      rect2.h = rect.h * screen.pixelHeight * scale;
      screen.render();
      pixmap.initTexture(this.ren);
      uint sx = screen.pixelHeight / min(screen.pixelWidth, screen.pixelHeight);
      uint sy = screen.pixelWidth / min(screen.pixelWidth, screen.pixelHeight);
      pixmap.updateTexture();
      if (this.draggedIcons.length > 0)
      {
        auto cm = screen.pixmap.copymode;
        int off = cast(int) min(3, this.draggedIcons.length) - 1;
        for (uint j = 0; j < min(3, this.draggedIcons.length); j++)
        {
          auto pix = this.draggedIcons[j];
          pixmap.copyToTexture(pix, false, off + screen.mouseX - pix.width / 2,
              off + screen.mouseY - pix.height / 2);
          off -= 2;
        }
      }
      if (this.pointer)
        pixmap.copyToTexture(this.pointer, true, screen.mouseX - this.pointerX * sx,
            screen.mouseY - this.pointerY * sy, sx, sy);
      SDL_RenderCopy(this.ren, pixmap.getTexture(), rect, rect2);
      rect2.y = dy + height * scale;
      SDL_RenderFillRect(ren, rect2);
    }
    if (this.lastmb == 0)
      this.oldAspect = oldAspect;
    SDL_RenderPresent(this.ren);
  }

  private void handleTextInput(TextEditor te, string txt)
  {
    const startBr = "'\"({[";
    const endBr = "'\")}]";
    const i = countUntil(startBr, txt);
    const j = countUntil(endBr, txt);
    if (j >= 0 && te.selectedBytes == 0 && te.pos1 < te.text.length && te.text[te.pos1] == txt[0])
    {
      te.right();
    }
    else if (i >= 0)
    {
      const sel = te.getSelectedText();
      const pos2 = min(te.pos1, te.pos2);
      te.insertText(startBr[i .. i + 1] ~ sel ~ endBr[i .. i + 1]);
      te.left();
      te.pos2 = pos2 + 1;
      te.recalculate();
    }
    else
    {
      te.insertText(txt);
    }
  }

  private void handleTextEdit(SDL_Keycode key)
  {
    if (!this.focusedViewport)
      return;
    if (!this.focusedViewport.getTextinput())
      return;
    TextEditor te = this.focusedViewport.getTextinput();
    if (SDL_GetModState() & KMOD_CTRL)
    {
      switch (key)
      {
      case SDLK_a:
        te.selectAll();
        break;
      case SDLK_z:
        te.undo();
        break;
      case SDLK_x:
        SDL_SetClipboardText(toStringz(te.getSelectedText()));
        te.insertText("");
        break;
      case SDLK_c:
        SDL_SetClipboardText(toStringz(te.getSelectedText()));
        break;
      case SDLK_v:
        te.insertText(to!string(cast(char*)(SDL_GetClipboardText())));
        break;
      default:
      }
    }
    switch (key)
    {
    case SDLK_TAB:
      if (te.selectedBytes > 0)
      {
        te.setSelectedBytes(te.selectedBytes);
        while (te.pos2 > 0 && te.text[te.pos2 - 1] != 10)
          te.pos2--;
        if (te.pos2 > 0)
          te.pos2--;
        if (te.pos1 > 0)
          te.pos1--;
        while (te.pos1 < te.text.length && te.text[te.pos1] != 10)
          te.pos1++;
        const ind = te.detectIndentation();
        const pos2 = min(te.pos1, te.pos2);
        const sel = te.getSelectedText();
        if (SDL_GetModState() & KMOD_SHIFT)
          te.insertText(replace(sel, "\n" ~ ind, "\n"));
        else
          te.insertText(replace(sel, "\n", "\n" ~ ind));
        te.pos2 = pos2;
        if (te.pos1 < te.text.length)
          te.pos1++;
        if (te.pos2 < te.text.length)
          te.pos2++;
        te.recalculate();
      }
      else
      {
        te.insertText("\t");
      }
      break;
    case SDLK_RETURN:
    case SDLK_KP_ENTER:
      if (SDL_GetModState() & KMOD_CTRL)
        te.end();
      te.insertText("\n");
      te.indent();
      break;
    case SDLK_BACKSPACE:
      te.backSpace(cast(bool)(SDL_GetModState() & KMOD_CTRL));
      break;
    case SDLK_DELETE:
      te.deleteChar(cast(bool)(SDL_GetModState() & KMOD_CTRL));
      break;
    case SDLK_RIGHT:
      if (SDL_GetModState() & KMOD_CTRL)
        te.nextWord(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      else
        te.right(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_LEFT:
      if (SDL_GetModState() & KMOD_CTRL)
        te.previousWord(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      else
        te.left(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_DOWN:
      te.down(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_UP:
      te.up(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_PAGEDOWN:
      te.pageDown(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_PAGEUP:
      te.pageUp(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_HOME:
      if (SDL_GetModState() & KMOD_CTRL)
        te.docStart(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      else
        te.home(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_END:
      if (SDL_GetModState() & KMOD_CTRL)
        te.docEnd(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      else
        te.end(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    default:
    }
  }

  private void handleGameCtrl()
  {
    if (!this.focusedViewport)
      return;
    if (this.focusedViewport.gameBtn.length != gameBtns.length)
      gameBtns.length = this.focusedViewport.gameBtn.length;
    for (ubyte i = 0; i < gameBtns.length; i++)
      gameBtns[i] = 0;
    ubyte* kbdState = SDL_GetKeyboardState(null);
    for (uint i = 0; i < this.gameBindings.length; i++)
      foreach (scancode, btn; this.gameBindings[i])
        if (kbdState[scancode])
          gameBtns[i] |= btn;

    if (this.hasGamepad)
      for (uint i = 1; i < gameBtns.length; i++)
      {
        gameBtns[i] |= gameBtns[i - 1];
        gameBtns[i - 1] = 0;
      }

    for (int i = 0; i < SDL_NumJoysticks(); i++)
    {
      auto gamepad = SDL_GameControllerOpen(i);
      if (gamepad)
      {
        if (SDL_GameControllerGetButton(gamepad, SDL_CONTROLLER_BUTTON_A))
          this.hasGamepad = true;
        gameBtns[i % $] |= GameBtns.right * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_DPAD_RIGHT);
        gameBtns[i % $] |= GameBtns.left * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_DPAD_LEFT);
        gameBtns[i % $] |= GameBtns.up * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_DPAD_UP);
        gameBtns[i % $] |= GameBtns.down * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_DPAD_DOWN);

        gameBtns[i % $] |= GameBtns.a * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_A);
        gameBtns[i % $] |= GameBtns.b * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_B);
        gameBtns[i % $] |= GameBtns.x * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_X);
        gameBtns[i % $] |= GameBtns.y * SDL_GameControllerGetButton(gamepad,
            SDL_CONTROLLER_BUTTON_Y);

        short lx = SDL_GameControllerGetAxis(gamepad, SDL_CONTROLLER_AXIS_LEFTX);
        short ly = SDL_GameControllerGetAxis(gamepad, SDL_CONTROLLER_AXIS_LEFTY);
        short rx = SDL_GameControllerGetAxis(gamepad, SDL_CONTROLLER_AXIS_RIGHTX);
        short ry = SDL_GameControllerGetAxis(gamepad, SDL_CONTROLLER_AXIS_RIGHTY);

        gameBtns[i % $] |= GameBtns.right * (lx > short.max / 2);
        gameBtns[i % $] |= GameBtns.left * (lx < short.min / 2);
        gameBtns[i % $] |= GameBtns.up * (ly < short.min / 2);
        gameBtns[i % $] |= GameBtns.down * (ly > short.max / 2);

        gameBtns[i % $] |= GameBtns.a * (rx > short.max / 2);
        gameBtns[i % $] |= GameBtns.b * (ry < short.min / 2);
        gameBtns[i % $] |= GameBtns.x * (rx < short.min / 2);
        gameBtns[i % $] |= GameBtns.y * (ry > short.max / 2);
      }
      SDL_GameControllerClose(gamepad);
    }

    ulong neo = 0;
    for (uint i = 0; i < gameBtns.length; i++)
    {
      neo *= 256;
      neo += gameBtns[i];
    }
    if (this.lastgmb != neo)
    {
      this.lastgmb = neo;
      this.newInput = true;
      for (uint i = 0; i < gameBtns.length; i++)
        this.focusedViewport.setGameBtn(gameBtns[i], cast(ubyte)(i + 1));
    }
  }

  private void initMidi()
  {
    version (Win64)
    {
      MnInputPort[] inputPorts = mnFetchInputs();
      foreach (MnInputPort port; inputPorts)
      {
        auto input = new MnInput();
        input.open(port);
        this.midiDevs ~= input;
      }
    }
  }

  private void handleMidi()
  {
    version (Win64)
    {
      if (SDL_GetTicks() > this.midiTimeout)
      {
        if (this.midiData.length)
          this.midiData = [];
      }
      foreach (MnInput input; this.midiDevs)
      {
        while (input.canReceive())
        {
          this.midiData ~= input.receive();
        }
      }
      this.newInput = this.newInput || this.hasMidi();
    }
  }
}

/**
  all the game buttons
*/
enum GameBtns
{
  right = 1,
  left = 2,
  up = 4,
  down = 8,
  a = 16,
  b = 32,
  x = 64,
  y = 128
}

/**
  all the permissions
*/
enum Permissions
{
  managePermissions = 1,
  mountLocalDrives = 2,
  mountRemoteDrives = 4,
  unmountDrives = 8,
  manageMainScreen = 16,
  managePrograms = 32,

  readOtherDrives = 256,
  writeOtherDrives = 512,
  readEnv = 1024,
  writeEnv = 2048
}
