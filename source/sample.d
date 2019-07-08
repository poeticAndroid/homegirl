module sample;

import std.string;
import std.file;
import core.stdc.stdlib;
import bindbc.sdl;

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
    load sample from wav file
  */
  void loadWav(string filename)
  {
    if (!isFile(filename))
      throw new Throwable("No such file " ~ filename);
    SDL_AudioSpec* wav_spec = new SDL_AudioSpec();
    ubyte* wav_buffer;
    uint wav_len;
    SDL_LoadWAV(toStringz(filename), wav_spec, &wav_buffer, &wav_len);
    this.freq = wav_spec.freq;
    while (this.freq > 28_867)
      this.freq /= 2;

    SDL_BuildAudioCVT(this.cvt, wav_spec.format, wav_spec.channels,
        wav_spec.freq, AUDIO_S8, 1, this.freq);
    this.cvt.len = wav_len;
    this.cvt.buf = cast(ubyte*) malloc(this.cvt.len * this.cvt.len_mult);
    for (uint i = 0; i < wav_len; i++)
      this.cvt.buf[i] = wav_buffer[i];
    SDL_ConvertAudio(this.cvt);
    this.data.length = this.cvt.len_cvt;
    for (uint i = 0; i < this.data.length; i++)
      this.data[i] = this.cvt.buf[i];

    SDL_FreeWAV(wav_buffer);
    free(cvt.buf);
  }

  // --- _privates --- //
  private SDL_AudioCVT* cvt = new SDL_AudioCVT();
}
