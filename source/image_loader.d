module image_loader;

import std.string;
import std.file;
import bindbc.freeimage;

import pixmap;

/**
  load image from file and return as pixmap
*/
Pixmap loadImage(string filename)
{
  if (!exists(filename) || !isFile(filename))
    throw new Throwable("No such file " ~ filename);
  FIBITMAP* img = FreeImage_Load(FIF_GIF, toStringz(filename));
  Pixmap pix = fibitmapToPixmap(img, null);
  FreeImage_Unload(img);
  return pix;
}

/**
  load animation from file and return as array of pixmaps
*/
Pixmap[] loadAnimation(string filename)
{
  Pixmap[] frames;
  Pixmap canvas = loadImage(filename);
  FIMULTIBITMAP* anim = FreeImage_OpenMultiBitmap(FIF_GIF, toStringz(filename), false, true, true);
  const count = FreeImage_GetPageCount(anim);
  for (uint i = 0; i < count; i++)
  {
    FIBITMAP* img = FreeImage_LockPage(anim, i);
    frames ~= fibitmapToPixmap(img, canvas).clone();
    FreeImage_UnlockPage(anim, img, false);
  }
  FreeImage_CloseMultiBitmap(anim);
  return frames;
}

/**
  Convert FIBITMAP to Pixmap
*/
Pixmap fibitmapToPixmap(FIBITMAP* img, Pixmap pixmap)
{
  const width = FreeImage_GetWidth(img);
  const height = FreeImage_GetHeight(img);
  ushort color = 1;
  ubyte maxindex;
  ubyte c;
  maxindex = cast(ubyte)(FreeImage_GetColorsUsed(img) - 1);
  if (!pixmap)
  {
    ubyte colorBits = 0;
    while (color < maxindex + 1)
    {
      color *= 2;
      colorBits++;
    }
    pixmap = new Pixmap(width, height, colorBits);
  }
  int left = 0;
  int top = 0;
  ubyte dispose = 0;
  FITAG* tag;
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "FrameTime", &tag);
  if (tag)
    pixmap.duration = cast(uint)(cast(long*) FreeImage_GetTagValue(tag))[0];
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "FrameLeft", &tag);
  if (tag)
    left = (cast(short*) FreeImage_GetTagValue(tag))[0];
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "FrameTop", &tag);
  if (tag)
    top = (cast(short*) FreeImage_GetTagValue(tag))[0];
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "DisposalMethod", &tag);
  if (tag)
    dispose = (cast(ubyte*) FreeImage_GetTagValue(tag))[0];

  pixmap.bgColor = cast(ubyte) FreeImage_GetTransparentIndex(img);
  if (dispose == 2)
    pixmap.cls();

  RGBQUAD* palette = FreeImage_GetPalette(img);
  if (palette)
    for (color = 0; color <= maxindex; color++)
      pixmap.setColor(color, palette[color].rgbRed / 16,
          palette[color].rgbGreen / 16, palette[color].rgbBlue / 16);
  for (uint y = 0; y < height; y++)
  {
    for (uint x = 0; x < width; x++)
    {
      FreeImage_GetPixelIndex(img, x, height - y - 1, &c);
      if (c != pixmap.bgColor)
        pixmap.pset(left + x, top + y, c);
    }
  }
  return pixmap;
}
