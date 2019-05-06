import std.stdio;
import std.file;
import std.json;
import std.string;
import riverd.lua;
import riverd.lua.types;
import bindbc.sdl;

import machine;
import program;

int main(string[] args)
{
  Machine machine;
  JSONValue config;
  // start machine
  try
  {
    machine = new Machine();
  }
  catch (Exception e)
  {
    writeln(e);
    return 1;
  }

  // read config
  try
  {
    config = parseJSON(readText("./config.json"));
    SDL_SetWindowPosition(machine.win, cast(int) config["window"].object["left"].integer,
        cast(int) config["window"].object["top"].integer,);
    SDL_SetWindowSize(machine.win, cast(int) config["window"].object["width"].integer,
        cast(int) config["window"].object["height"].integer,);
    if (config["window"].object["maximized"].boolean)
      SDL_MaximizeWindow(machine.win);
    if (config["window"].object["fullscreen"].boolean)
      machine.toggleFullscren();
  }
  catch (Exception e)
  {
    writeln("no config!");
  }

  // run machine
  machine.programs ~= new Program(machine, "startup.lua");
  while (machine.running)
  {
    machine.step();
  }

  // write config
  try
  {
    config = parseJSON(readText("./config.json"));
  }
  catch (Exception e)
  {
    config = parseJSON("{ \"window\":{} }");
  }
  int x;
  int y;
  x = SDL_GetWindowFlags(machine.win);
  config["window"].object["maximized"] = JSONValue((x & SDL_WINDOW_MAXIMIZED) ? true : false);
  config["window"].object["fullscreen"] = JSONValue((x & SDL_WINDOW_FULLSCREEN_DESKTOP) ? true
      : false);
  if (!(x & (SDL_WINDOW_MAXIMIZED | SDL_WINDOW_FULLSCREEN_DESKTOP)))
  {
    SDL_GetWindowPosition(machine.win, &x, &y);
    config.object["window"].object["left"] = JSONValue(x);
    config.object["window"].object["top"] = JSONValue(y);
    SDL_GetWindowSize(machine.win, &x, &y);
    config["window"].object["width"] = JSONValue(x);
    config["window"].object["height"] = JSONValue(y);
  }
  auto configFile = File("./config.json", "w");
  configFile.write(toJSON(config));
  configFile.close();

  //shutdown machine
  machine.shutdown();
  writeln("THE END!");
  return 0;
}
