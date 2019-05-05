module machine;

import std.stdio;
import std.string;
import std.format;
import std.math;
import bindbc.sdl;

import screen;
import pixmap;
import program;

/**
  Class representing "the machine"!
*/
class Machine
{
  bool running = true; /// is the machine running?
  bool fullscreen = false; /// is the machine running in full screen?
  Screen[] screens; /// all the screens
  Program[] programs; /// all the programs currently running on the machine

  /**
    Create a new machine
  */
  this()
  {
    this.init_window();
    this.screens ~= new Screen(3, 5);
  }

  /**
    advance the machine one step
  */
  void step()
  {
    // Event loop
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      switch (event.type)
      {
      case SDL_QUIT:
        running = false;
        break;
      case SDL_KEYDOWN:
        this.screens[0].top = 0;
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
    for (uint i = 0; i < this.programs.length; i++)
    {
      Program program = this.programs[i];
      if (program)
      {
        if (!program.running)
        {
          program.shutdown();
          this.programs[i] = null;
        }
        else
        {
          program.step(SDL_GetTicks());
        }
      }
    }
    this.draw_screens();
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
      {
        program.shutdown();
        this.programs[i] = null;
      }
    }
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
  }

  // === _privates === //
  private SDL_Window* win; /// the main window
  private SDL_Renderer* ren; /// the main renderer
  private auto rect = new SDL_Rect();
  private auto rect2 = new SDL_Rect();

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
        SDL_WINDOWPOS_UNDEFINED, 1280 + 32, 720 + 18, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
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
  }

  private void draw_screens()
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
      dx = (dx - pixmap.width * screen.pixelWidth * scale) / 2;
      dy = (dy - pixmap.height * screen.pixelHeight * scale) / 2;
      dy += screen.top * scale;

      SDL_SetRenderDrawColor(ren, pixmap.palette[0], pixmap.palette[1], pixmap.palette[2], 255);
      if (screen.top <= 0)
        SDL_RenderClear(ren);
      else
      {
        this.rect.x = 0;
        this.rect.y = dy - scale * 3;
        SDL_GetWindowSize(this.win, &this.rect.x, &this.rect.y);
        SDL_RenderFillRect(ren, rect);
      }
      rect.x = 0;
      rect.y = 0;
      rect.w = pixmap.width;
      rect.h = pixmap.height;
      rect2.x = dx;
      rect2.y = dy;
      rect2.w = pixmap.width * screen.pixelWidth * scale;
      rect2.h = pixmap.height * screen.pixelHeight * scale;
      screen.render();
      if (!pixmap.texture)
        pixmap.createTexture(this.ren);
      pixmap.updateTexture();
      SDL_RenderCopy(this.ren, pixmap.texture, rect, rect2);
    }
    SDL_RenderPresent(this.ren);
  }

  private void toggleFullscren()
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
}
