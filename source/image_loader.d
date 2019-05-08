module image_loader;

import std.string;
import bindbc.freeimage;

import pixmap;

/**
  load image from file and return as pixmap
*/
Pixmap loadImage(string filename)
{
  FIBITMAP* img = FreeImage_Load(FIF_GIF, toStringz(filename), GIF_LOAD256);
  const width = FreeImage_GetWidth(img);
  const height = FreeImage_GetHeight(img);
  ubyte maxindex;
  ubyte c;
  for (uint y = 0; y < height; y++)
  {
    for (uint x = 0; x < width; x++)
    {
      FreeImage_GetPixelIndex(img, x, y, &c);
      if (c > maxindex)
        maxindex = c;
    }
  }
  ubyte colorBits = 0;
  c = 1;
  while (c < maxindex + 1)
  {
    c *= 2;
    colorBits++;
  }
  Pixmap pixmap = new Pixmap(width, height, colorBits);
  RGBQUAD* palette = FreeImage_GetPalette(img);
  for (c = 0; c <= maxindex; c++)
    pixmap.setColor(c, palette[c].rgbRed / 16, palette[c].rgbGreen / 16, palette[c].rgbBlue / 16);
  for (uint y = 0; y < height; y++)
  {
    for (uint x = 0; x < width; x++)
    {
      FreeImage_GetPixelIndex(img, x, height - y, &c);
      pixmap.pset(x, y, c);
    }
  }
  FreeImage_Unload(img);
  return pixmap;
}
