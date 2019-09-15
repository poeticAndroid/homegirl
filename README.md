![Icon](./images/homegirl.png) Homegirl
========
It's a fantasy console (like pico-8 or tic-80) inspired by the Amiga!

![Amigaaah!](./images/homegirl_screentitles.gif)

[![Download!](./images/download.gif)![Icon](./images/homegirl.png)](https://github.com/poeticAndroid/homegirl/releases/latest)

It has graphic resolutions similar to the OCS Amigas, multitasking, multiple screens and windows etc.. It has 4 channel 8-bit stereo sound and ability to mount web-servers as drives..

The software for it, is based on Lua, which is a pretty simple and fast scripting language..

Once the console is somewhat complete, I plan on writing an "operating system" for it in Lua, which would resemble Workbench.. or you could even make your own, if you wanted..

Hopefully I would also get to make some decent tools, like text editor, music editor and paint program, so that you could make games or apps on the platform itself..!

[**Join the community on Discord!**](https://discord.gg/ND4FErK)

Specs
-----
 - **Programming language:** Lua ([See wiki for API documentation](https://github.com/poeticAndroid/homegirl/wiki))
 - **Screen resolutions:** 32 screen modes ranging from 80x45 to 640x480 pixels
 - **Number of colors:** Up to 256 colors from a palette of 4096 colors
 - **Audio:** Four 8-bit PCM channels in stereo, playback up to 24 kHz
 - **Input:** Text, mouse, game input and MIDI(Windows only)..
 - **Filesystem:** Named drives which can be mapped to local folders or websites
 - **Native filetypes:** GIF for images and animations, WAV for sound samples

Installation
------------
Download and extract [latest release](https://github.com/poeticAndroid/homegirl/releases/latest) for your OS and run the `homegirl` executable from the same folder.. If it doesn't work, make sure you have the following libraries installed (a setup script may be provided):

  - [SDL2 2.0.8](https://www.libsdl.org/)
  - [Lua 5.3](https://www.lua.org/)
  - [FreeImage 3.18](http://freeimage.sourceforge.net/)
  - libcurl ([Windows](http://downloads.dlang.org/other/index.html) | [other](https://curl.haxx.se/libcurl/))
