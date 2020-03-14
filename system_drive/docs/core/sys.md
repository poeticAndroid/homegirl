`sys` module
============
System functions.

**`sys.read(): string`**  
Read text from standard input.

**`sys.write(string)`**  
Write text to standard output.

**`sys.err(string)`**  
Write text to standard error output.

**`sys.stepinterval([milliseconds]): milliseconds`**  
Get/set the minimum amount of time between each stepping of the program. By default this is set to `-1`, which means that the program will only be stepped whenever there is new input.

**`sys.listenv(): keys[]`**  
Get a list of all environment variables on the system.

**`sys.env(key[, value]): value`**  
Get/set a given environment variable on the system.

**`sys.time(): hour, minute, second, UTCoffset`**  
Get the current local time.

**`sys.date(): year, month, date, weekday`**  
Get the current local date.

**`sys.exit([code])`**  
End the program with given exitcode when this step is done. This will call the `_shutdown` function with the given exitcode.

**`sys.exec(filename[, args[][, cwd]]): success`**  
Load and run given program independently of this program.

**`sys.killall(programname): count`**  
Kill all instances of a given program and return the number of instances killed.

**`sys.lookbusy()`**  
Show busy pointer for the rest of the step.

**`sys.permissions(drive[, perms]): perms`**  
Get/set permissions for a given drive. `perms` is the sum of the corresponding values listed below.

**`sys.requestedpermissions(drive[, perms]): perms`**  
Get/set requested permissions for a given drive. `perms` is the sum of the corresponding values listed below.

Value | Permission
------|-----------
1 | Manage permissions
2 | Mount local drives
4 | Mount remote drives
8 | Unmount other drives
16 | Manage main screen
32 | Manage programs
256 | Read other drives
512 | Write to other drives
1024 | Read environment variables
2048 | Set environment variables

Child programs
--------------
**`sys.startchild(filename[, args[]]): child`**  
Load and run given program as a child and return it.

**`sys.childrunning(child): bool`**  
Return `true` if given child is still running.

**`sys.childexitcode(child): int`**  
Return exitcode of given child.

**`sys.writetochild(child, str)`**  
Send given str to given child's default input.

**`sys.readfromchild(child): str`**  
Read from given child's default output.

**`sys.errorfromchild(child): str`**  
Read from given child's error output.

**`sys.killchild(child)`**  
Force child to end itself.

**`sys.forgetchild(child)`**  
Forget about that child.
