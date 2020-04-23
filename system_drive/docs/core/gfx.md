`gfx` module
============
These functions require that a [screen or other viewport](view.md) is created and active.

**`gfx.cls()`**  
Fill the entire active viewport with the current background color.

**`gfx.palette(color[, red, green, blue]): red, green, blue`**  
Get/set the RGB values of a given color index. Each value can range from 0 to 15.

**`gfx.fgcolor([color]): color`**  
Get/set the current foreground color of the active viewport.

**`gfx.bgcolor([color]): color`**  
Get/set the current background color of the active viewport.

**`gfx.nearestcolor(r, g, b): color`**  
Get the color nearest the given RGB values from the palette of the active viewport.

**`gfx.pixel(x, y[, color]): color`**  
Get/set the color of a given pixel in the active viewport.

**`gfx.plot(x, y)`**  
Set the given pixel to the current foreground color.

**`gfx.bar(x, y, width, height)`**  
Draw a rectangle filled with the current foreground color.

**`gfx.line(x1, y1, x2, y2)`**  
Draw a line with the current foreground color.

**`gfx.tri(x1, y1, x2, y2, x3, y3)`**  
Draw a filled triangle with the current foreground color.
