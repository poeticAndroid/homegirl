`input` module
==============
These functions require that a [screen or other viewport](view.md) is created and active.

Text input
----------
**`input.text([text]): text`**  
Get/set the text currently entered into the active viewport.

**`input.selected([text]): text`**  
Get the text that is currently selected or enter given text at cursor.

**`input.cursor([pos, selected]): pos, selected`**  
Get/set the cursor position and selection length in bytes.

**`input.linesperpage([linesperpage]): linesperpage`**  
Get/set the number of lines to jump on PageUp/Down.

**`input.clearhistory()`**  
Clear undo history in active viewport.

Other input
-----------
**`input.hotkey(): hotkey`**  
Get the key that was just pressed in conjunction with Ctrl(unless it's Esc or Tab). This will reset each step.

**`input.mouse(): x, y, btn`**  
Get the current mouse coordinates relative to the active viewport and any mouse buttons currently pressed, if the viewport has focus.

**`input.drag(drop, icon)`**  
Add a string for the mouse pointer to drag and an icon to represent it. This only works as long as active viewport has focus and a mouse button is held down. Mouse button input will be suppressed as long as something is being dragged.

**`input.drop(): drop`**  
Catch something currently being dropped into the active viewport or return `nil`.

**`input.midi(): byte`**  
Read a byte of data from MIDI.

**`input.gamepad([player]): btn`**  
Get the gamepad state of given player. Player can be either 0, 1 or 2. If player is 0 then the states of both players will be combined.

Each button can be tested like this:

```lua
    right = btn & 1 > 0
    left = btn & 2 > 0
    up = btn & 4 > 0
    down = btn & 8 > 0
    A = btn & 16 > 0
    B = btn & 32 > 0
    X = btn & 64 > 0
    Y = btn & 128 > 0
```