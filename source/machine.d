module machine;

import std.string;
import std.format;
import std.math;
import bindbc.sdl;

import pixmap;
import program;

/**
  Class representing "the machine"!
*/
class Machine
{
  bool running = true; /// is the machine running?
  Pixmap screen = new Pixmap(320, 180, 128); /// screen memory
  Program program; /// the program currently running on the machine

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
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      switch (event.type)
      {
      case SDL_QUIT:
        running = false;
        break;
      default:
      }
    }
    if (this.program)
    {
      this.program.step();
      this.draw_screen();
    }
  }

  /**
    shutdown the machine
  */
  void shutdown()
  {
    this.running = false;
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
  }

  // === _privates === //
  private SDL_Window* win; /// the main window
  private SDL_Renderer* ren; /// the main renderer
  private auto rect = new SDL_Rect();

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
    this.win = SDL_CreateWindow("Homegirl", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        this.screen.width * 4 + 16, this.screen.height * 4 + 16,
        SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    if (win == null)
    {
      SDL_Quit();
      throw new Exception(format("SDL_CreateWindow Error: %s", SDL_GetError()));
    }

    this.ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren == null)
    {
      SDL_DestroyWindow(win);
      SDL_Quit();
      throw new Exception(format("SDL_CreateRenderer Error: %s", SDL_GetError()));
    }
  }

  private void draw_screen()
  {
    uint i;
    int dx;
    int dy;
    SDL_GetWindowSize(this.win, &dx, &dy);
    int scale = cast(int) fmax(1.0, floor(fmin(dx / this.screen.width, dy / this.screen.height)));
    dx = (dx - this.screen.width * scale) / 2;
    dy = (dy - this.screen.height * scale) / 2;
    this.rect.w = scale;
    this.rect.h = scale;
    auto pixmap = this.screen;

    SDL_SetRenderDrawColor(ren, 0, 0, 0, 0);
    SDL_RenderClear(ren);
    for (int y = 0; y < pixmap.height; y++)
    {
      for (int x = 0; x < pixmap.width; x++)
      {
        i = pixmap.pixels[y * pixmap.width + x] * 3;
        SDL_SetRenderDrawColor(ren, pixmap.palette[i++], pixmap.palette[i++],
            pixmap.palette[i++], 255);
        rect.x = dx + x * cast(int) scale;
        rect.y = dy + y * cast(int) scale;
        SDL_RenderFillRect(ren, rect);
      }
    }
    SDL_RenderPresent(ren);
  }
}
