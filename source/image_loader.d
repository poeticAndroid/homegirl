module image_loader;

import std.string;
import std.file;
import std.stdio;
import bindbc.freeimage;

import pixmap;

/**
  load image from file and return as pixmap
*/
Pixmap loadImage(string filename)
{
  if (!exists(filename) || !isFile(filename))
    throw new Exception("No such file " ~ filename);
  FIMEMORY* mem = readfile(filename);
  FIBITMAP* img = FreeImage_LoadFromMemory(FIF_GIF, mem);
  FreeImage_CloseMemory(mem);
  Pixmap pix = fibitmapToPixmap(img, null);
  FreeImage_Unload(img);
  return pix;
}

/**
  load animation from file and return as array of pixmaps
*/
Pixmap[] loadAnimation(string filename, uint maxframes = -1)
{
  Pixmap[] frames;
  Pixmap canvas = loadImage(filename);
  // FIMULTIBITMAP* anim;
  FIMEMORY* mem = readfile(filename);
  FIMULTIBITMAP* anim = FreeImage_LoadMultiBitmapFromMemory(FIF_GIF, mem);
  uint count = FreeImage_GetPageCount(anim);
  if (maxframes < count)
    count = maxframes;
  for (uint i = 0; i < count; i++)
  {
    FIBITMAP* img = FreeImage_LockPage(anim, i);
    frames ~= fibitmapToPixmap(img, canvas).clone();
    FreeImage_UnlockPage(anim, img, false);
  }
  FreeImage_CloseMultiBitmap(anim);
  FreeImage_CloseMemory(mem);
  return frames;
}

/**
  save animation to file
*/
void saveAnimation(string filename, Pixmap[] frames)
{
  FIMULTIBITMAP* anim = FreeImage_OpenMultiBitmap(FIF_GIF, toStringz(filename), true, false, true);
  const count = frames.length;
  for (uint i = 0; i < count; i++)
  {
    FIBITMAP* img = pixmapToFibitmap(frames[i]);
    FreeImage_AppendPage(anim, img);
    FreeImage_Unload(img);
  }
  FreeImage_CloseMultiBitmap(anim);
}

/**
  read file into a FIMEMORY stream
*/
FIMEMORY* readfile(string filename)
{
  ubyte[] bin = cast(ubyte[]) read(filename);
  FIMEMORY* mem = FreeImage_OpenMemory(cast(ubyte*) bin, cast(uint) bin.length);
  return mem;
}

/**
  write a FIMEMORY stream to a file
*/
void writefile(string filename, FIMEMORY* mem)
{
  ubyte* bin;
  DWORD len;
  FreeImage_AcquireMemory(mem, &bin, &len);
  auto f = File(filename, "wb");
  for (uint i = 0; i < len; i++)
    f.write(bin[i]);
  f.close();
  // write(filename, staticArray(bin, len));
}

/**
  Convert FIBITMAP to Pixmap
*/
Pixmap fibitmapToPixmap(FIBITMAP* img, Pixmap pixmap)
{
  const width = FreeImage_GetWidth(img);
  const height = FreeImage_GetHeight(img);

  int time = 100;
  int left = 0;
  int top = 0;
  ubyte dispose = 0;
  FITAG* tag;
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "FrameTime", &tag);
  if (tag)
    time = cast(uint)(cast(long*) FreeImage_GetTagValue(tag))[0];
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "FrameLeft", &tag);
  if (tag)
    left = (cast(short*) FreeImage_GetTagValue(tag))[0];
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "FrameTop", &tag);
  if (tag)
    top = (cast(short*) FreeImage_GetTagValue(tag))[0];
  FreeImage_GetMetadata(FIMD_ANIMATION, img, "DisposalMethod", &tag);
  if (tag)
    dispose = (cast(ubyte*) FreeImage_GetTagValue(tag))[0];

  ushort color = 1;
  ubyte c;
  ubyte maxindex = cast(ubyte)(FreeImage_GetColorsUsed(img) - 1);
  if (!pixmap)
  {
    ubyte colorBits = 0;
    while (color < maxindex + 1)
    {
      color *= 2;
      colorBits++;
    }
    pixmap = new Pixmap(width, height, colorBits);
    dispose = 2;
  }

  pixmap.duration = time;
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

/**
  Convert Pixmap to FIBITMAP
*/
FIBITMAP* pixmapToFibitmap(Pixmap pixmap)
{
  auto bpp = pixmap.colorBits;
  if (bpp > 8)
    bpp = 8;
  while (bpp != 1 && bpp != 4 && bpp != 8)
    bpp++;
  FIBITMAP* img = FreeImage_Allocate(pixmap.width, pixmap.height, bpp);
  FITAG* tag = FreeImage_CreateTag();
  FreeImage_SetTagKey(tag, "FrameTime");
  FreeImage_SetTagType(tag, FIDT_LONG);
  FreeImage_SetTagCount(tag, 1);
  FreeImage_SetTagLength(tag, 4);
  FreeImage_SetTagValue(tag, &pixmap.duration);
  FreeImage_SetMetadata(FIMD_ANIMATION, img, "FrameTime", tag);
  ubyte dismet = 2;
  FreeImage_SetTagKey(tag, "DisposalMethod");
  FreeImage_SetTagType(tag, FIDT_BYTE);
  FreeImage_SetTagCount(tag, 1);
  FreeImage_SetTagLength(tag, 1);
  FreeImage_SetTagValue(tag, &dismet);
  FreeImage_SetMetadata(FIMD_ANIMATION, img, "DisposalMethod", tag);
  uint colors = cast(uint)(pixmap.palette.length / 3);
  RGBQUAD* palette = FreeImage_GetPalette(img);
  for (uint c = 0; c < colors; c++)
  {
    palette[c].rgbRed = cast(ubyte)(pixmap.palette[c * 3 + 0]);
    palette[c].rgbGreen = cast(ubyte)(pixmap.palette[c * 3 + 1]);
    palette[c].rgbBlue = cast(ubyte)(pixmap.palette[c * 3 + 2]);
  }
  FreeImage_SetTransparentIndex(img, pixmap.bgColor);
  for (uint y = 0; y < pixmap.height; y++)
  {
    for (uint x = 0; x < pixmap.width; x++)
    {
      ubyte c = pixmap.pget(x, y);
      FreeImage_SetPixelIndex(img, x, pixmap.height - y - 1, &c);
    }
  }
  FreeImage_DeleteTag(tag);
  return img;
}
