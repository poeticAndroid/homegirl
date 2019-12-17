module screen;

import viewport;
import pixmap;

/**
  Class representing a screen
*/
class Screen : Viewport
{
  static bool widescreen; /// whether to do 16:9 or 4:3 aspect ratio
  ubyte pixelWidth; /// width of each pixel
  ubyte pixelHeight; /// height of each pixel

  /**
    create a new screen
  */
  this(ubyte mode, ubyte colorBits)
  {
    super(null, 0, 0, 0, 0, 0);
    this.changeMode(mode, colorBits);
    // this.defaultPointer();
  }

  override
  {
    /**
      change screen mode
    */
    void changeMode(ubyte mode, ubyte colorBits)
    {
      this.pixmap.destroyTexture();
      if (mode > 31)
        throw new Exception("Unsupported screen mode!");
      if (colorBits > 8)
        throw new Exception("Unsupported number of colorBits!");
      mode = mode % 16;
      this.mode = mode;
      this.pixelWidth = 8;
      this.pixelHeight = 8;
      for (uint i = 0; i < (mode % 4); i++)
        this.pixelWidth /= 2;
      mode /= 4;
      for (uint i = 0; i < (mode % 4); i++)
        this.pixelHeight /= 2;
      mode /= 4;
      uint height = 360;
      if (!Screen.widescreen)
        height = 480;
      if (this.program)
        this.program.freeMemory(this.memoryUsed());
      this.pixmap.destroyTexture();
      Pixmap oldpix = this.pixmap;
      this.pixmap = new Pixmap(640 / this.pixelWidth, height / this.pixelHeight, colorBits);
      this.pixmap.viewport = this;
      this.pixmap.copyRectFrom(oldpix, 0, 0, 0, 0, oldpix.width, oldpix.height);
      this.pixmap.setFGColor(oldpix.fgColor);
      this.pixmap.setBGColor(oldpix.bgColor);
      this.pixmap.copymode = oldpix.copymode;
      this.pixmap.textCopymode = oldpix.textCopymode;
      if (oldpix.palette.length == this.pixmap.palette.length)
        this.pixmap.palette = oldpix.palette;
      this.setDirty();
      if (this.program)
        this.program.useMemory(this.memoryUsed());
    }

    /**
      screens are not resizable
    */
    void resize(uint width, uint height)
    {
    }
  }

  void defaultPointer()
  {
    this.pointer = new Pixmap(11, 11, 2);
    this.pointer.pixels = [
      1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 1, 0, 0, 0, 0, 1, 3,
      3, 3, 3, 2, 1, 0, 0, 0, 0, 1, 3, 3, 3, 2, 1, 0, 0, 0, 0, 0, 1, 3, 3, 3,
      3, 2, 1, 0, 0, 0, 0, 1, 3, 3, 1, 3, 3, 2, 1, 0, 0, 0, 0, 1, 1, 0, 1, 3,
      3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3,
      3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0
    ];
    this.pointerX = 0;
    this.pointerY = 0;
  }
}
