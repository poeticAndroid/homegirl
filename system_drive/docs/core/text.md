`text` module
=============
Homegirl uses GIF files as fonts. Each character is stored as a frame and the character width is stored as the frame's duration in centiseconds.

[See example](https://raw.githubusercontent.com/poeticAndroid/homegirl/master/system_drive/fonts/Victoria.8b.gif)

Managing fonts
--------------
**`text.loadfont(fontname): font`**  
Load a font and return it. If `fontname` doesn't refer directly to a filename, it will search the program directory, the `fonts` folder on the root of the origin drive and `sys:` drive, in that order.

**`text.forgetfont(font)`**  
Forget about that font.

Printing text on the screen
---------------------------
These functions require that a [screen or other viewport](view) is created and active.

**`text.copymode([mode, masked]): mode, masked`**  
Get/set the [copy mode](image) regarding text.

**`text.draw(text, font, x, y): width, height`**  
Draw given text with given font at given spot and return the size of the text in pixels.
