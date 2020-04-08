`image` module
==============
Homegirl and load and save frames from GIF animations. Each frame has its own palette (converted from 24 to 12 bit colors) and exposure duration. Since the screen can only show up to 256 colors at once, GIF files that depend on accumulating palettes will not work.

Creating and managing images
----------------------------
**`image.new(width, height, colorbits): img`**  
Create a blank image with given width, height and [colorbits](view.md) and return it.

**`image.load(filename[, maxframes]): img[]`**  
Read a GIF file and return a table of its frames.

**`image.save(filename, img[]): success`**  
Write a given table of images to a GIF file and return `true` if succesful.

**`image.size(img): width, height`**  
Get the width and height of a given image.

**`image.colordepth(img): colorbits`**  
Get the number of colorbits per pixel of a given image.

**`image.forget(img)`**  
Erase image from memory.


Manipulating images
-------------------
**`image.duration(img[, milliseconds]): milliseconds`**  
Get/set the exposure time of a given image.

**`image.pixel(img, x, y[, color]): color`**  
Get/set the color of a given pixel in a given image.

**`image.palette(img, color[, red, green, blue]): red, green, blue`**  
Get/set the RGB values of a given color index. Each value can range from 0 to 15.

**`image.bgcolor(img[, color]): color`**  
Get/set the current background color of a given image.


Drawing images
--------------
These functions require that a [screen or other viewport](view.md) is created and active.

**`image.copymode([mode, masked]): mode, masked`**  
Get/set the current copy mode of the active viewport. If `masked` is `true` then all background pixels from source will not be copied.

Mode | Name | Effect
-----|------|-------
 0|  zero       | always index 0
 1|  conNonimpl | dest </- src
 2|  and        | dest and src
 3|  source     | always source index (default mode)
 4|  matNonimpl | dest -/> src
 5|  xor        | dest xor src
 6|  dest       | always destination index
 7|  or         | dest or src
 8|  not        | inverts destination index
 9|  min        | lowest index of destination or source
10|  max        | highest index of destination or source
11|  average    | average index of destination or source
12|  add        | sum of destination and source index
13|  subtract   | destination index minus source index
14|  multiply   | product of destination and source index
15|  divide     | destination index divided by source index
16|  bgcolor,         | always background index
17|  fgcolor,         | always foreground index
18|  srcbgColor,      | always background color of source
20|  sourceColor,     | always source color
21|  darkerColor,     | darkest combination of destination and source colors
22|  lighterColor,    | lightest combination of destination and source colors
23|  averageColor,    | average of destination and source colors
24|  addColor,        | sum of destination and source colors (capped at white)
25|  subtractColor,   | destination color minus source color (capped at black)
26|  multiplyColor,   | product of destination and source colors
28|  hueColor,        | destination color with the hue of source color
29|  saturationColor, | destination color with the saturation of source color
30|  lightnessColor,  | destination color with the lightness of source color
31|  graynessColor,   | destination color with the saturation and lightness of source color


**`image.errordiffusion([enabled]): enabled`**  
Get/set whether or not error diffusion is enabled when using copymodes above 17 or the `gfx.nearestcolor` function.

**`image.tri(img, x1,y1, x2,y2, x3,y3, imgx1,imgy1, imgx2,imgy2, imgx3,imgy3)`**  
Draw a given triangular portion of given image to a given triangular spot on the active viewport.

**`image.draw(img, x, y, imgx, imgy, width, height[, imgwidth, imgheight])`**  
Draw a given rectangular portion of given image to a given rectangular spot on the active viewport.

**`image.copy(img, x, y, imgx, imgy, width, height)`**  
Copy a given portion of the active viewport to a given spot on given image. (Copy mode will always be 0 here.)

**`image.usepalette(img)`**  
Copy the palette from a given image to the active screen. This only works if a screen is active.

**`image.copypalette(img)`**  
Copy the palette from the active screen to given image.

**`image.busypointer(img, Xoffset, Yoffset)`**  
Set the given image as busy pointer. Color palette works the same as with `image.pointer`.

**`image.pointer(img, Xoffset, Yoffset)`**  
Set the given image as mouse pointer for the active viewport. Only 4 color images are supported and the colors are automatically assigned to the following:

Index | Color
------|------
0 | transparent
1 | darkest color in the palette
2 | lightest color in the palette
3 | most saturated color in the palette
