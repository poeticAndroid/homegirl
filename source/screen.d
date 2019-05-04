module screen;

import pixmap;

class Screen
{
  Pixmap pixmap;
  uint position = 0;
  ubyte pixelWidth;
  ubyte pixelHeight;

  this(ubyte mode, ubyte colorBits)
  {
    switch (mode)
    {
    case 0:
      this.pixmap = new Pixmap(320, 180, colorBits);
      this.pixelWidth = 2;
      this.pixelHeight = 2;
      break;
    case 1:
      this.pixmap = new Pixmap(640, 180, colorBits);
      this.pixelWidth = 1;
      this.pixelHeight = 2;
      break;
    case 2:
      this.pixmap = new Pixmap(320, 360, colorBits);
      this.pixelWidth = 2;
      this.pixelHeight = 1;
      break;
    case 3:
      this.pixmap = new Pixmap(640, 360, colorBits);
      this.pixelWidth = 1;
      this.pixelHeight = 1;
      break;
    default:
      throw new Exception("Unsupported screen mode " ~ mode);
    }
  }
}
