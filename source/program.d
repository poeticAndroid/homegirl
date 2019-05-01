module program;

import riverd.lua;
import riverd.lua.types;

import machine;

/**
  a program that the machine can run
*/
class Program
{
  Machine machine; /// the machine that this program runs on
  lua_State* lua; /// Lua state

  /** 
    Initiate a new program!
  */
  this(Machine machine)
  {
    this.machine = machine;
    // Load the Lua library.
    dylib_load_lua();
    this.lua = luaL_newstate();
    registerFunctions(this);
  }

  /**
    advance the program one step
  */
  void step()
  {
  }

  // === _privates === //
  // private void registerFunctions()
  // {
  //   auto program = this;

  // }
}

void registerFunctions(Program program)
{
  auto lua = program.lua;
  extern (C) int pset(lua_State* L)
  {
    long x = lua_tointeger(L, -2);
    long y = lua_tointeger(L, -1);
    program.machine.screen.pset(cast(uint) x, cast(uint) y);
    return 0;
  }

  lua_register(lua, "pset", &pset);

}
