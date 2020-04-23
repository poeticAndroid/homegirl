`audio` module
==============
The audio system of Homegirl consists of 4 digital 8-bit channels (numbered 0 to 3) evenly spread between left and right speaker.

    L[0...1...2...3]R

Each channel can play up to one sample at a time. Playback frequency (sample values per second), volume and loop markers can be altered during playback for each channel independently. Maximum playbackrate is 32000.

Creating and managing audio samples
-----------------------------------
**`audio.new(): sampl`**  
Create a new empty audio sample and return it.

**`audio.load(filename): sampl`**  
Load audio sample from `.wav` file and return it. The audio will automatically be converted to 8-bit mono and the samplerate halfed until it is 32 kHz or less.

**`audio.save(filename, sampl): success`**  
Save audio sample to `.wav` file and return `true` on success.

**`audio.forget(sampl)`**  
Erase given audio sample from memory.

Playing audio samples
---------------------
**`audio.play(channel, sampl)`**  
Play audio sample on given channel. Channel playback frequency and loop markers will automatically be set according to the given sample. The channel volume will be set to maximum.

**`audio.channelfreq(channel[, freq]): freq`**  
Get/set the playback frequency of the given channel. Any frequency above 32 kHz will be halfed until it is 32 kHz or less. Once an audio sample has finished playing, playback frequency will be set to 0;

**`audio.channelhead(channel[, pos]): pos`**  
Get/set the current playback position (in number of sample values) on the given channel.

**`audio.channelvolume(channel[, volume]): volume`**  
Get/set the volume (0 to 63) of the given channel.

**`audio.channelloop(channel[, start, end]): start, end`**  
Get/set the loop markers of the given channel. To disable loop, set both markers to `0`.

Manipulating audio samples
--------------------------
**`audio.samplevalue(sampl, pos[, value]): value`**  
Get/set value (-128 to 127) of given audio sample at given position. If given position is beyond the length of the sample, an error will occur.

**`audio.samplelength(sampl[, length]): length`**  
Get/set the length of given audio sample in number of sample values.

**`audio.samplefreq(sampl[, freq]): freq`**  
Get/set the inherent playback frequency of the given audio sample.

**`audio.sampleloop(sampl[, start, end]): start, end`**  
Get/set the inherent loop markers of the given audio sample.

**`audio.record(sampl): bytes`**  
Record from the input audio device to the given sample at the given sample's frequency and return number of bytes added to given sample.

