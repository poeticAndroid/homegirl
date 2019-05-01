import std.stdio;
import riverd.lua;
import riverd.lua.types;

import machine;
import program;

int main(string[] args)
{
	Machine machine;
	try
	{
		machine = new Machine();
	}
	catch (Exception e)
	{
		writeln(e);
		return 1;
	}

	machine.program = new Program(machine);
	while (machine.running)
	{
		machine.step();
	}

	machine.shutdown();
	writeln("THE END!");
	return 0;
}
