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
	Program program; /// the program currently running on the machine

	/**
		Create a new machine
	*/
	this()
	{
		this.init_window();
		this.screens ~= new Screen(0, 5);
		this.screens ~= new Screen(0, 5);
		this.screens[1].position = 300;
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
				this.screens[0].position = 0;
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

		// advance the program
		if (this.program)
		{
			if (!this.program.running)
			{
				this.program.shutdown();
				this.program = null;
			}
			else
			{
				this.program.step(SDL_GetTicks());
			}
			this.draw_screen();
		}
		this.screens[0].position++;
	}

	/**
		shutdown the machine
	*/
	void shutdown()
	{
		this.running = false;
		if (this.program)
		{
			this.program.shutdown();
			this.program = null;
		}
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
		this.win = SDL_CreateWindow("Homegirl", SDL_WINDOWPOS_UNDEFINED,
				SDL_WINDOWPOS_UNDEFINED, 1280 + 16, 720 + 16, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
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

	private void draw_screen()
	{
		const width = 640;
		const height = 360;
		int dx;
		int dy;
		SDL_GetWindowSize(this.win, &dx, &dy);
		if (dx < width)
			SDL_SetWindowSize(this.win, width, dy);
		if (dy < height)
			SDL_SetWindowSize(this.win, dx, height);
		uint scale = cast(int) fmax(1.0, floor(fmin(dx / width, dy / height)));
		for (uint i = 0; i < this.screens.length; i++)
		{
			Screen screen = this.screens[i];
			int nextPos = height;
			if (this.screens.length > i + 1)
				nextPos = this.screens[i + 1].position;
			if (screen.position >= nextPos)
				continue;
			nextPos = (nextPos - screen.position) / screen.pixelHeight;
			uint pi = 0;
			uint pa = 0;
			dx = (dx - screen.pixmap.width * screen.pixelWidth * scale) / 2;
			dy = (dy - screen.pixmap.height * screen.pixelHeight * scale) / 2;
			dy += screen.position * scale;

			auto pixmap = screen.pixmap;
			SDL_SetRenderDrawColor(ren, pixmap.palette[pa++], pixmap.palette[pa++],
					pixmap.palette[pa++], 255);
			if (screen.position < 1)
				SDL_RenderClear(ren);
			else
			{
				this.rect.x = 0;
				this.rect.y = dy - scale * 3;
				SDL_GetWindowSize(this.win, &this.rect.x, &this.rect.y);
				SDL_RenderFillRect(ren, rect);
			}
			this.rect.w = scale * screen.pixelWidth;
			this.rect.h = scale * screen.pixelHeight;
			for (uint y = 0; y < pixmap.height; y++)
			{
				if (y >= nextPos)
					break;
				for (uint x = 0; x < pixmap.width; x++)
				{
					pa = pixmap.pixels[pi++] * 3 % pixmap.palette.length;
					SDL_SetRenderDrawColor(ren, pixmap.palette[pa++],
							pixmap.palette[pa++], pixmap.palette[pa++], 255);
					rect.x = dx + x * screen.pixelWidth * scale;
					rect.y = dy + y * screen.pixelHeight * scale;
					SDL_RenderFillRect(ren, rect);
				}
			}
		}
		SDL_RenderPresent(ren);
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
