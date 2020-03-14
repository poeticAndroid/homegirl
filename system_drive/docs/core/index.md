Developing for Homegirl
=======================
The Homegirl console is based on the [Lua programming language](https://www.lua.org/). All of the Lua standard library is available, except for `io`, `file`, `os` and most of the `package` module. But Homegirl also has its own API, which is documented in the other pages of this wiki. 👉

Special functions
-----------------
Each program can define three special functions, which will be called automatically at certain times.

**`_init(args[])`**  
This will be called immediately after the program has been loaded and initialized. The `args` parameter is a table of strings which is passed from the command line or another program.

**`_step(time)`**  
This will be called at regular intervals or (by default) whenever a key/button is pressed/released or mouse is dragged. The `time` parameter is the amount of time in milliseconds the console has been running for.

**`_shutdown(exitcode)`**  
This will only be called if the program exits by itself or another program kills it. It will not be called if there is an error in the program. The `exitcode` parameter is the numeric code that the program exits with. This is usually an error code, if the program didn't succeed at its task, or `0` if it did. If the program was killed, the exit code will be `-1`.

Special constants
-----------------
**`_DRIVE`**  
This will automatically be set to the drive that contains the current program file, regardless of current working directory.

**`_DIR`**  
This will automatically be set to the directory that contains the current program file, regardless of current working directory.

**`_FILE`**  
This will automatically be set to the name of the current program file.
