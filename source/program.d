module program;

import std.random;
import bindbc.sdl;

import machine;

/**
  a program that the machine can run
*/
class Program
{
  Machine machine; /// the machine that this program runs on

  /// constructor
  this(Machine machine)
  {
    this.machine = machine;
  }

  /**
    advance the program one step
  */
  void step()
  {
    for (uint y = 0; y < machine.screen.height; y++)
    {
      for (uint x = 0; x < machine.screen.width; x++)
      {
        machine.screen.pset(x, y, cast(ubyte) uniform(0, 64));
      }
    }
  }
}
