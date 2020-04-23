Using the Homegirl console
==========================
To use Homegirl, download and extract the zip file. If you're on Windows, run `homegirl_windows.exe`, else run `homegirl.sh`.

Keyboard hotkeys
----------------
Key | Action
----|---------
Ctrl+F4 | Kill the program of the front-most screen (unless it's the main screen).
F7      | Auto-resize and center window
F8      | Sync audio buffer
F9      | Toggle CRT filter
F11     | Toggle Fullscreen
F12     | Open config folder

Configuration
-------------
Homegirl is configured with a config file, discovered in the following order:

 1. specified as a command line argument. (filename has to end with `.json`)
 2. `homegirl.json` in the current working directory.
 3. `%APPDATA%\Homegirl\config.json` if on Windows.
 4. `~/.config/Homegirl/config.json` or `config.json` in the current working directory if no home directory can be found.

If a config file can't be found, a default file will be created.

