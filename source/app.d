import std.stdio;
import std.file;
import std.json;
import bindbc.sdl;
import bindbc.freeimage;

import machine;
import program;

int main(string[] args)
{
  Machine machine;
  JSONValue config;
  const ret = loadFreeImage();
  if (ret == FISupport.noLibrary)
    writeln("Couldn't load FreeImage!");

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
    if (config["window"].type == JSONType.object)
    {
      if ("left" in config["window"] && "top" in config["window"])
        SDL_SetWindowPosition(machine.win, cast(int) config["window"].object["left"].integer,
            cast(int) config["window"].object["top"].integer,);
      if ("width" in config["window"] && "height" in config["window"])
        SDL_SetWindowSize(machine.win, cast(int) config["window"].object["width"].integer,
            cast(int) config["window"].object["height"].integer,);
      if ("maximized" in config["window"] && config["window"].object["maximized"].boolean)
        SDL_MaximizeWindow(machine.win);
      if ("fullscreen" in config["window"] && config["window"].object["fullscreen"].boolean)
        machine.toggleFullscren();
    }
  }
  catch (Exception e)
  {
    writeln("no config!");
  }

  // run machine
  // machine.startProgram("startup.lua");
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
  configFile.write(toJSON(config, true));
  configFile.close();

  //shutdown machine
  machine.shutdown();
  writeln("You Homegirl computer is now powered off.");
  return 0;
}
