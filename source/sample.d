module sample;

import std.stdio;
import std.string;
import std.file;
import core.stdc.stdlib;

/**
  Sound sample
*/
class Sample
{
  byte[] data; /// sample data
  int freq = 11_025; /// samplerate
  uint loopStart = 0; /// start of loop
  uint loopEnd = 0; /// end of loop

  /**
    create sound sample
  */
  this(string filename)
  {
    if (filename)
      this.loadWav(filename);
  }

  /**
    calculate memory usage of this sample
  */
  uint memoryUsed()
  {
    return cast(uint) this.data.length;
  }

  /**
    load sample from wav file
  */
  void loadWav(string filename)
  {
    char[4] tag;
    ubyte[1] b;
    ushort[1] s;
    uint[1] i;
    auto f = File(filename, "rb");
    if (this.nextChunk(f) != "RIFF")
      throw new Exception("Unsupported format!");
    if (f.rawRead(tag) != "WAVE")
      throw new Exception("Unsupported format!");
    while (f.eof() == false && this.nextChunk(f) != "fmt ")
      this.skipChunk(f);
    ushort audioFormat = f.rawRead(s)[0];
    ushort numChannels = f.rawRead(s)[0];
    uint sampleRate = f.rawRead(i)[0];
    uint byteRate = f.rawRead(i)[0];
    ushort blockAlign = f.rawRead(s)[0];
    ushort bitsPerSample = f.rawRead(s)[0];
    if (audioFormat != 1)
      throw new Exception("Unsupported format!");
    while (sampleRate > 32_000)
    {
      numChannels *= 2;
      sampleRate /= 2;
    }
    this.freq = sampleRate;
    this.skipChunk(f);
    while (!f.eof() && this.nextChunk(f) != "data")
      this.skipChunk(f);
    uint p = cast(uint)(this.nextChuckOffset - f.tell());
    p /= numChannels * (bitsPerSample / 8);
    this.data.length = p;
    p = 0;
    uint skip = numChannels * (bitsPerSample / 8) - 1;
    for (uint n = 1; n < (bitsPerSample / 8); n++)
      f.rawRead(b);
    while (!f.eof() && p < this.data.length)
    {
      f.rawRead(b);
      if ((bitsPerSample / 8) > 1)
        this.data[p++] = b[0];
      else
        this.data[p++] = b[0] - 128;
      for (uint n = 0; !f.eof() && n < skip; n++)
        f.rawRead(b);
    }
    this.data.length = p;
    f.close();
    // this._loadWav(filename);
  }

  /**
    save sample to wav file
  */
  void saveWav(string filename)
  {
    ubyte[] b;
    ushort[] s;
    uint[] i;
    auto f = File(filename, "wb");
    f.rawWrite("RIFF");
    i = [36 + cast(uint) this.data.length];
    f.rawWrite(i);
    f.rawWrite("WAVE");
    f.rawWrite("fmt ");
    i = [16];
    f.rawWrite(i);
    s = [1, 1];
    f.rawWrite(s);
    i = [this.freq, this.freq];
    f.rawWrite(i);
    s = [1, 8];
    f.rawWrite(s);
    f.rawWrite("data");
    i = [cast(uint) this.data.length];
    f.rawWrite(i);
    b.length = this.data.length;
    for (uint n = 0; n < b.length; n++)
      b[n] = this.data[n] + 128;
    f.rawWrite(b);
    f.close();
  }

  // --- _privates --- //
  private long nextChuckOffset;

  private char[4] nextChunk(File f)
  {
    char[4] tag;
    uint[1] i;
    f.rawRead(tag);
    f.rawRead(i);
    this.nextChuckOffset = f.tell() + i[0];
    return tag;
  }

  private void skipChunk(File f)
  {
    f.seek(this.nextChuckOffset);
  }

}
