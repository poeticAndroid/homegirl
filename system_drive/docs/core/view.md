`view` module
=============
The display system of Homegirl consists of a tree of viewports. The top level of viewports are screens which are layered on top of each other. Each screen be configured in different screen modes and color depths and can have their own tree of viewports which inherit the pixel resolution and colors of the screen.

The first screen created since console startup will become the main screen. Any program can create viewports (to make windows) on the main screen. With the right permission, programs can also manage the main screen by passing `nil` as the `view` parameter in most of these functions.

Creating and removing viewports
-------------------------------
**`view.newscreen(mode, colorbits): view`**  
Create a new screen in given screen mode and colorbits, make it active and return it. The number of colors will be 2 raised to the power of `colorbits`.

Mode | Width | Height 16:9 | Height 4:3 | Pixel size (ratio)
-----|-------|-------------|------------|------------------
   0 |    80 |          45 |         60 |        8x8 (1:1)
   1 |   160 |          45 |         60 |        4x8 (1:2)
   2 |   320 |          45 |         60 |        2x8 (1:4)
   3 |   640 |          45 |         60 |        1x8 (1:8)
   4 |    80 |          90 |        120 |        8x4 (2:1)
   5 |   160 |          90 |        120 |        4x4 (1:1)
   6 |   320 |          90 |        120 |        2x4 (1:2)
   7 |   640 |          90 |        120 |        1x4 (1:4)
   8 |    80 |         180 |        240 |        8x2 (4:1)
   9 |   160 |         180 |        240 |        4x2 (2:1)
  10 |   320 |         180 |        240 |        2x2 (1:1)
  11 |   640 |         180 |        240 |        1x2 (1:2)
  12 |    80 |         360 |        480 |        8x1 (8:1)
  13 |   160 |         360 |        480 |        4x1 (4:1)
  14 |   320 |         360 |        480 |        2x1 (2:1)
  15 |   640 |         360 |        480 |        1x1 (1:1)

**`view.new(parentview, left, top, width, height): view`**  
Create a new subviewport to given parent viewport, make it active and return it. If `parentview` is `nil`, then the viewport will be created on the main screen.

**`view.remove(view)`**  
Remove and forget about given viewport.

Managing viewports
------------------
**`view.screenmode(view[, mode, colorbits]): mode, colorbits`**  
If given viewport is a screen, this will get/set its screen mode and colorbits.

**`view.active([view]): view`**  
Get/set the currently active viewport.

**`view.position(view[, left, top]): left, top`**  
Get/set the position of given viewport.

**`view.size(view[, width, height]): width, height`**  
Get/set the size of given viewport.

**`view.visible(view[, isvisible]): isvisible`**  
Get/set whether given viewport is visible.

**`view.focused(view[, isfocused]): isfocused`**  
Get/set whether given viewport has input focus.

**`view.zindex(view[, index]): index`**  
Get/set the z-index of given viewport. `0` sends the viewport to the back of its parent. `-1` brings it to the front.

**`view.children(view): views[]`**  
Get all sub-viewports of given viewport.

**`view.owner(view): programname`**  
Get the programname of the program that created the given viewport.

**`view.attribute(view, name[, value]): value`**  
Get/set a given attribute of a given viewport.
