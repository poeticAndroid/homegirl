module pixmap;

import std.random;

/**
  index-based pixel map
*/
class Pixmap
{
  uint width; /// width of pixel map
  uint height; /// height of pixel map
  ubyte[] pixels; /// all the pixels
  ubyte[] palette; /// the color palette

  /**
    create new pixmap
  */
  this(uint width, uint height, ubyte colors)
  {
    this.width = width;
    this.height = height;
    this.pixels.length = this.width * this.height;
    this.palette.length = colors * 3;
    auto rnd = Random(42);
    for (uint i = 0; i < this.pixels.length; i++)
    {
      this.pixels[i] = 0;
    }
    for (uint i = 3; i < this.palette.length; i++)
    {
      this.palette[i] = cast(ubyte) uniform(0, 255, rnd);
    }
  }

  /**
    edit a color in the color palette
  */
  void setColor(uint index, ubyte red, ubyte green, ubyte blue)
  {
    uint i = 3 * index;
    this.palette[i + 0] = red;
    this.palette[i + 1] = green;
    this.palette[i + 2] = blue;
  }

  /**
    get color of specific pixel
  */
  ubyte pget(uint x, uint y)
  {
    if (x >= this.width || y >= this.height)
      return 0;
    uint i = y * this.width + x;
    return this.pixels[i];
  }

  /**
    set color of specific pixel
  */
  void pset(uint x, uint y, ubyte color)
  {
    if (x >= this.width || y >= this.height)
      return;
    uint i = y * this.width + x;
    this.pixels[i] = color;
  }

}
