module pixmap;

import std.stdio;
import bindbc.sdl;

/**
  index-based pixel map
*/
class Pixmap
{
  uint width; /// width of pixel map
  uint height; /// height of pixel map
  ubyte colorBits; /// bits per color
  ubyte fgColor = 1; /// index of foreground color
  ubyte bgColor = 255; /// index of background/transparent color
  ubyte[] pixels; /// all the pixels
  ubyte[] palette; /// the color palette
  SDL_Texture* texture; /// texture representation of pixmap

  /**
    create new pixmap
  */
  this(uint width, uint height, ubyte colorBits)
  {
    this.width = width;
    this.height = height;
    this.colorBits = colorBits;

    uint colors = 1;
    for (ubyte i = 0; i < colorBits; i++)
      colors *= 2;
    this.palette.length = colors * 3;
    for (ubyte i = 0; i < colors; i++)
    {
      this.setColor(i, i, i, i);
    }

    this.pixels.length = this.width * this.height;
    for (uint i = 0; i < this.pixels.length; i++)
    {
      this.pixels[i] = 0;
    }
  }

  void createTexture(SDL_Renderer* ren)
  {
    this.texture = SDL_CreateTexture(ren, SDL_PIXELFORMAT_BGR888,
        SDL_TEXTUREACCESS_STREAMING, this.width, this.height);
  }

  void updateTexture()
  {
    // SDL_UpdateTexture(this.texture, null, cast(void**) this.pixels, this.width);
    ubyte* pixels = null;
    int pitch;
    SDL_LockTexture(this.texture, null, cast(void**)&pixels, &pitch);
    uint src = 0;
    uint dest = 0;
    for (uint i = 0; i < this.pixels.length; i++)
    {
      src = this.pixels[i] * 3 % this.palette.length;
      pixels[dest++] = this.palette[src++];
      pixels[dest++] = this.palette[src++];
      pixels[dest++] = this.palette[src++];
      pixels[dest++] = 255;
    }
    SDL_UnlockTexture(this.texture);
  }

  /**
    edit a color in the color palette
  */
  void setColor(uint index, ubyte red, ubyte green, ubyte blue)
  {
    uint i = 3 * index;
    this.palette[i + 0] = (red % 16) * 17;
    this.palette[i + 1] = (green % 16) * 17;
    this.palette[i + 2] = (blue % 16) * 17;
  }

  /**
    get color of specific pixel
  */
  ubyte pget(uint x, uint y)
  {
    if (x >= this.width || y >= this.height)
      return this.bgColor;
    const i = y * this.width + x;
    return this.pixels[i];
  }

  /**
    set color of specific pixel
  */
  void pset(uint x, uint y, ubyte c)
  {
    if (x >= this.width || y >= this.height)
      return;
    uint i = y * this.width + x;
    this.pixels[i] = c;
  }

  /**
    set specific pixel to foreground color
  */
  void plot(int x, int y)
  {
    this.pset(x, y, this.fgColor);
  }

  /**
    copy pixels from another pixmap
  */
  void copyFrom(Pixmap src, int sx, int sy, int dx, int dy, uint w, uint h)
  {
    for (uint y = 0; y < h; y++)
    {
      for (uint x = 0; x < w; x++)
      {
        ubyte c = src.pget(sx + x, sy + y);
        if (c != src.bgColor)
          this.pset(dx + x, dy + y, c);
      }
    }
  }

}
