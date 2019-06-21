module screen;

import viewport;
import pixmap;

/**
  Class representing a screen
*/
class Screen : Viewport
{
  ubyte pixelWidth; /// width of each pixel (1 or 2)
  ubyte pixelHeight; /// height of each pixel (1 or 2)

  /**
    create a new screen
  */
  this(ubyte mode, ubyte colorBits)
  {
    super(null, 0, 0, 0, 0, 0);
    this.changeMode(mode, colorBits);
  }

  override
  {
    /**
      change screen mode
    */
    void changeMode(ubyte mode, ubyte colorBits)
    {
      this.pixmap.destroyTexture();
      if (mode > 15)
        throw new Exception("Unsupported screen mode!");
      if (colorBits > 5)
        throw new Exception("Unsupported number of colorBits!");
      this.pixelWidth = 8;
      this.pixelHeight = 8;
      for (uint i = 0; i < (mode % 4); i++)
        this.pixelWidth /= 2;
      mode /= 4;
      for (uint i = 0; i < (mode % 4); i++)
        this.pixelHeight /= 2;
      this.pixmap = new Pixmap(640 / this.pixelWidth, 360 / this.pixelHeight, colorBits);
    }

    /**
      screens are not resizable
    */
    void resize(uint width, uint height)
    {
    }
  }
}
