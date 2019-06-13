module soundchip;

import std.string;
import bindbc.sdl;

class SoundChip
{
  this()
  {
    this.init();
  }

  void init()
  {
    SDL_AudioSpec* wav_spec = new SDL_AudioSpec();
    ubyte* wav_buffer;
    uint wav_len;
    SDL_LoadWAV(toStringz("./examples/sounds/COMP2_10.WAV"), wav_spec, &wav_buffer, &wav_len);

    SDL_AudioSpec* want = new SDL_AudioSpec();
    want.freq = 48000;
    want.format = AUDIO_S16;
    want.channels = 2;
    want.samples = 1024;
    auto dev = SDL_OpenAudioDevice(null, 0, wav_spec, null, 0);

    SDL_QueueAudio(dev, wav_buffer, wav_len);
    SDL_PauseAudioDevice(dev, 0);
    SDL_FreeWAV(wav_buffer);
  }
}
