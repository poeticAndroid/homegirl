module machine;

import std.string;
import std.format;
import std.math;
import std.algorithm.searching;
import std.algorithm.mutation;
import std.path;
import std.file;
import std.conv;
import bindbc.sdl;

import viewport;
import screen;
import program;
import texteditor;
import soundchip;

const VERSION = "0.1.12"; /// version of the software

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
  Program[] programs; /// all the programs currently running on the machine
  ubyte[uint][2] gameBindings; /// keyboard bindings to game input
  bool hasGamepad = false; /// has a gamepad been used?
  uint cursorBlank = 0; /// when to hide the cursor if idle
  SoundChip audio; /// audio output
  string[string] drives; /// a table of all the console drives and their corresponding host folder
  string[string] env; /// environment variables

  /**
    Create a new machine
  */
  this()
  {
    if (loadSDL() != sdlSupport)
      throw new Exception("SDL not work! :(");
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK) != 0)
      throw new Exception(format("SDL_Init Error: %s", SDL_GetError()));

    this.init_window();
    this.audio = new SoundChip();
    this.env["Homegirl_version"] = VERSION;
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
        SDL_ShowCursor(SDL_ENABLE);
        break;
      case SDL_TEXTINPUT:
        this.newInput = true;
        if (this.focusedViewport && this.focusedViewport.textinput)
          this.focusedViewport.textinput.insertText(to!string(cast(char*) event.text.text));
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

    // advance the programs
    uint runningPrograms = 0;
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program program = this.programs[i];
      if (program)
      {
        runningPrograms++;
        if (!program.running)
          this.shutdownProgram(program);
        else
        {
          if (program.nextStep == 0)
            this.newInput = true;
          if ((program.stepInterval < 0 && newInput)
              || (program.stepInterval >= 0 && program.nextStep <= SDL_GetTicks()))
            program.step(SDL_GetTicks());
        }
      }
    }
    this.newInput = false;

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
    create new screen
  */
  Screen createScreen(ubyte mode, ubyte colorBits)
  {
    Screen screen = new Screen(mode, colorBits);
    this.screens ~= screen;
    if (!this.mainScreen)
      this.mainScreen = screen;
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
      screen.pixmap.destroyTexture();
      screen.detach();
    }
  }

  /**
    make a viewport focused
  */
  void focusViewport(Viewport vp)
  {
    this.focusedViewport = vp;
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
  }

  /**
    bind key to game input
  */
  void bindGameBtn(uint player, uint scancode, ubyte btn)
  {
    this.gameBindings[player][scancode] = btn;
  }

  /**
    mount a drive
  */
  void mountDrive(string name, string path)
  {
    name = toUpper(name);
    path = absolutePath(path);
    if (this.drives.get(name, null))
      throw new Throwable("Drive '" ~ name ~ "' already mounted!");
    if (!exists(path) || !isDir(path))
      mkdirRecurse(path);
    if (path[$ - 1 .. $] != dirSeparator)
      path ~= dirSeparator;
    this.drives[name] = path;
  }

  /**
    unmount a drive
  */
  void unmountDrive(string name)
  {
    name = toUpper(name);
    if (!this.drives.get(name, null))
      return;
    uint inUse = 0;
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program program = this.programs[i];
      if (program && (this.getDrive(program.filename, "") == name
          || this.getDrive(program.cwd, "") == name))
        inUse++;
    }
    if (inUse)
      throw new Throwable("Drive '" ~ name ~ "' is in use!");
    this.drives[name] = null;
  }

  /**
    resolve console path to host path
  */
  string actualPath(string consolePath)
  {
    string drive = this.getDrive(consolePath, "");
    if (!drive)
      throw new Throwable("Invalid console path!");
    if (!this.drives.get(drive, null))
      throw new Throwable("No such drive!");
    string path = consolePath[drive.length + 1 .. $];
    return buildNormalizedPath(this.drives[drive], path);
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
      return toUpper(path[0 .. i]) ~ end;
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

  // === _privates === //
  private SDL_Renderer* ren; /// the main renderer
  private auto rect = new SDL_Rect();
  private auto rect2 = new SDL_Rect();
  private int lastmx = 0;
  private int lastmy = 0;
  private uint lastmb = 0;
  private ulong lastgmb = 0;
  private uint scale;
  private uint bootupState = 5;
  private uint nextBootup;
  private bool newInput;
  private bool oldAspect;

  private void init_window()
  {
    // Create a window
    this.win = SDL_CreateWindow(toStringz("Homegirl " ~ VERSION), SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED, 640 + 48, 360 + 48, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    if (win == null)
    {
      SDL_Quit();
      throw new Exception(format("SDL_CreateWindow Error: %s", SDL_GetError()));
    }
    SDL_SetWindowIcon(this.win, SDL_LoadBMP("assets/icon.bmp"));
    this.ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren == null)
    {
      SDL_DestroyWindow(win);
      SDL_Quit();
      throw new Exception(format("SDL_CreateRenderer Error: %s", SDL_GetError()));
    }
    SDL_StartTextInput();
  }

  private void trackMouse()
  {
    if (SDL_GetTicks() > this.cursorBlank)
    {
      SDL_ShowCursor(SDL_DISABLE);
      this.cursorBlank += 1024;
    }
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
      screen.mouseBtn = 0;
      Viewport _vp = screen.setMouseXY(mx / screen.pixelWidth, (my - screen.top) / screen
          .pixelHeight);
      if (_vp)
        vp = _vp;
      if (screen.containsViewport(this.focusedViewport))
        validFocus = validFocus || true;
    }
    if ((this.lastmb == 0 && mb == 1) || !validFocus)
      this.focusViewport(vp);
    if (this.focusedViewport)
      this.focusedViewport.setMouseBtn(mb);
    if (this.lastmb != mb)
    {
      this.newInput = true;
      this.lastmb = mb;
    }
    if (mb && (this.lastmx != mx || this.lastmy != my))
    {
      this.newInput = true;
      this.lastmx = mx;
      this.lastmy = my;
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
    for (uint i = 0; i < this.screens.length; i++)
    {
      auto screen = this.screens[i];
      if (screen.top < 0)
        screen.top = 0;
      if (screen.top > height)
        screen.top = height;
      auto pixmap = screen.pixmap;
      int nextPos = height;
      if (this.screens.length > i + 1)
        nextPos = this.screens[i + 1].top;
      if (screen.top >= nextPos)
        continue;
      if (screen.pixmap.height * screen.pixelHeight > 400)
        oldAspect = true;

      SDL_SetRenderDrawColor(ren, pixmap.palette[0], pixmap.palette[1], pixmap.palette[2], 255);
      if (screen.top <= highest)
      {
        SDL_RenderClear(ren);
        highest = screen.top;
      }
      else
      {
        this.rect.x = 0;
        this.rect.y = dy + screen.top * scale - 8 * scale;
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
      if (!pixmap.texture)
        pixmap.initTexture(this.ren);
      pixmap.updateTexture();
      SDL_RenderCopy(this.ren, pixmap.texture, rect, rect2);
      rect2.y = dy + height * scale;
      SDL_RenderFillRect(ren, rect2);
    }
    if (this.lastmb == 0)
      this.oldAspect = oldAspect;
    SDL_RenderPresent(this.ren);
  }

  private void handleTextEdit(SDL_Keycode key)
  {
    if (!this.focusedViewport)
      return;
    if (!this.focusedViewport.textinput)
      return;
    TextEditor te = this.focusedViewport.textinput;
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
      te.insertText("\t");
      break;
    case SDLK_RETURN:
    case SDLK_KP_ENTER:
      te.insertText("\n");
      break;
    case SDLK_BACKSPACE:
      te.backSpace();
      break;
    case SDLK_DELETE:
      te.deleteChar();
      break;
    case SDLK_RIGHT:
      te.right(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_LEFT:
      te.left(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_DOWN:
      te.down(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_UP:
      te.up(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_HOME:
      te.home(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    case SDLK_END:
      te.end(cast(bool)(SDL_GetModState() & KMOD_SHIFT));
      break;
    default:
    }
  }

  private void handleGameCtrl()
  {
    if (!this.focusedViewport)
      return;
    ubyte[] gameBtns = this.focusedViewport.gameBtn;
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
      this.focusedViewport.setGameBtn(gameBtns[i], cast(ubyte)(i + 1));
    }
    if (this.lastgmb != neo)
    {
      this.lastgmb = neo;
      this.newInput = true;
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
