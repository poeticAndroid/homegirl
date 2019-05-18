module machine;

import std.stdio;
import std.string;
import std.format;
import std.math;
import std.algorithm.searching;
import std.algorithm.mutation;
import bindbc.sdl;

import viewport;
import screen;
import program;
import texteditor;

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

  /**
    Create a new machine
  */
  this()
  {
    this.init_window();
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
      switch (event.type)
      {
      case SDL_QUIT:
        running = false;
        break;
      case SDL_TEXTINPUT:
        if (this.focusedViewport)
          this.focusedViewport.textinput.insertText(
              cast(string) fromStringz(cast(char*)(event.text.text)));
        break;
      case SDL_KEYDOWN:
        if (this.focusedViewport)
        {
          if ((SDL_GetModState() & KMOD_CTRL && event.key.keysym.sym < 128)
              || event.key.keysym.sym == 9 || event.key.keysym.sym == 27)
            this.focusedViewport.setHotkey(cast(char) event.key.keysym.sym);
        }

        this.handleTextEdit(event.key.keysym.sym);
        switch (event.key.keysym.sym)
        {
        case SDLK_F11:
          this.toggleFullscren();
          break;
        default:
        }
        break;
      default:
      }
    }

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
          program.step(SDL_GetTicks());
      }
    }

    this.drawScreens();
    if (runningPrograms == 0)
      this.running = false;
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
  void startProgram(string filename)
  {
    this.programs ~= new Program(this, filename);
  }

  /**
    shut down a program
  */
  void shutdownProgram(Program program)
  {
    auto i = countUntil(this.programs, program);
    program.shutdown();
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

  // === _privates === //
  private SDL_Renderer* ren; /// the main renderer
  private auto rect = new SDL_Rect();
  private auto rect2 = new SDL_Rect();
  private uint lastmb = 0;

  private void init_window()
  {
    const SDLSupport ret = loadSDL();
    if (ret != sdlSupport)
    {
      throw new Exception("SDL not work! :(");
    }

    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
      throw new Exception(format("SDL_Init Error: %s", SDL_GetError()));
    }

    // Create a window
    this.win = SDL_CreateWindow("Homegirl", SDL_WINDOWPOS_UNDEFINED,
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
    const width = 640;
    const height = 360;
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
    uint mb = SDL_GetMouseState(&mx, &my);
    if (mx > dx)
      mx = (mx - dx) / scale;
    else
      mx = ((dx - mx) / scale) * -1;
    if (my > dy)
      my = (my - dy) / scale;
    else
      my = ((dy - my) / scale) * -1;

    Viewport vp;
    for (uint i = 0; i < this.screens.length; i++)
    {
      auto screen = this.screens[i];
      screen.mouseBtn = 0;
      Viewport _vp = screen.setMouseXY(mx / screen.pixelWidth, (my - screen.top) / screen
          .pixelHeight);
      if (_vp)
        vp = _vp;
    }
    if (mb > this.lastmb)
      this.focusViewport(vp);
    if (this.focusedViewport)
      this.focusedViewport.setMouseBtn(mb);
    this.lastmb = mb;
  }

  private void drawScreens()
  {
    const width = 640;
    const height = 360;
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

    bool first = true;
    for (uint i = 0; i < this.screens.length; i++)
    {
      auto screen = this.screens[i];
      if (screen.top < 0)
        screen.top = 0;
      if (screen.top > 360)
        screen.top = 360;
      auto pixmap = screen.pixmap;
      int nextPos = height;
      if (this.screens.length > i + 1)
        nextPos = this.screens[i + 1].top;
      if (screen.top >= nextPos)
        continue;

      SDL_SetRenderDrawColor(ren, pixmap.palette[0], pixmap.palette[1], pixmap.palette[2], 255);
      if (first)
      {
        SDL_RenderClear(ren);
        first = false;
      }
      else
      {
        this.rect.x = 0;
        this.rect.y = dy + screen.top * scale - 4 * scale;
        SDL_GetWindowSize(this.win, &this.rect.w, &this.rect.h);
        SDL_RenderFillRect(ren, rect);
      }
      rect.x = 0;
      rect.y = 0;
      rect.w = pixmap.width;
      rect.h = pixmap.height - screen.top / screen.pixelHeight;
      rect2.x = dx;
      rect2.y = dy + screen.top * scale;
      rect2.w = rect.w * screen.pixelWidth * scale;
      rect2.h = rect.h * screen.pixelHeight * scale;
      screen.render();
      if (!pixmap.texture)
        pixmap.initTexture(this.ren);
      pixmap.updateTexture();
      SDL_RenderCopy(this.ren, pixmap.texture, rect, rect2);
    }
    SDL_RenderPresent(this.ren);
  }

  private void handleTextEdit(SDL_Keycode key)
  {
    if (!this.focusedViewport)
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
        te.insertText(cast(string) fromStringz(cast(char*)(SDL_GetClipboardText())));
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

}
