import std.stdio;
import std.file;
import std.path;
import std.json;
import std.process : environment;
import bindbc.sdl;
import bindbc.freeimage;

import machine;
import program;

int main(string[] args)
{
  writeln("Powering on...");
  Machine machine;
  JSONValue config;
  string configFileName;

  version (Windows)
  {
    configFileName = buildNormalizedPath(environment["APPDATA"], "Homegirl/config.json");
  }
  else
  {
    if ("HOME" in environment)
      configFileName = buildNormalizedPath(environment["HOME"], ".config/Homegirl/config.json");
    else
      configFileName = "./config.json";
  }
  if (exists("./homegirl.json") && isFile("./homegirl.json"))
    configFileName = "./homegirl.json";
  if (args.length > 1 && args[$ - 1][$ - 5 .. $] == ".json")
    configFileName = args[$ - 1];
  writeln("Config file: ", configFileName);

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
    config = parseJSON(readText(configFileName));
  }
  catch (Exception e)
  {
    writeln("no config!");
    config = parseJSON("{}");
  }
  if ("window" in config && config["window"].type == JSONType.object)
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
  if ("drives" in config && config["drives"].type == JSONType.object)
  {
    string[] drives = config["drives"].object.keys();
    for (uint i = 0; i < drives.length; i++)
      machine.mountDrive(drives[i], config["drives"].object[drives[i]].str);
  }
  else
  {
    machine.mountDrive("sys", "./system_drive/");
    version (Windows)
    {
      machine.mountDrive("user", buildNormalizedPath(environment["APPDATA"],
          "Homegirl/user_drive/"));
    }
    else
    {
      if ("HOME" in environment)
        machine.mountDrive("user", buildNormalizedPath(environment["HOME"],
            ".config/Homegirl/user_drive/"));
      else
        machine.mountDrive("user", buildNormalizedPath("./user_drive/"));
    }
  }
  if ("gameBindings" in config && config["gameBindings"].type == JSONType.object)
  {
  }
  else
    setDefaultGameBindings(machine);

  // run machine
  // machine.startProgram("startup.lua");
  while (machine.running)
  {
    machine.step();
  }

  // write config
  try
  {
    config = parseJSON(readText(configFileName));
  }
  catch (Exception e)
  {
    config = parseJSON("{}");
  }
  if (!("window" in config))
    config["window"] = parseJSON("{}");
  config["drives"] = parseJSON("{}");
  // config["gameBindings"] = parseJSON("{}");
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
  for (uint i = 0; i < machine.drives.keys().length; i++)
    config["drives"].object[machine.drives.keys()[i]] = machine.drives[machine.drives.keys()[i]];

  auto configFile = File(configFileName, "w");
  configFile.write(toJSON(config, true));
  configFile.close();

  //shutdown machine
  machine.shutdown();
  writeln("Powered off.");
  return 0;
}

/**
  set default game bindings
*/
void setDefaultGameBindings(Machine machine)
{
  machine.bindGameBtn(0, SDL_SCANCODE_G, GameBtns.right);
  machine.bindGameBtn(0, SDL_SCANCODE_D, GameBtns.left);
  machine.bindGameBtn(0, SDL_SCANCODE_R, GameBtns.up);
  machine.bindGameBtn(0, SDL_SCANCODE_F, GameBtns.down);
  machine.bindGameBtn(0, SDL_SCANCODE_A, GameBtns.a);
  machine.bindGameBtn(0, SDL_SCANCODE_S, GameBtns.b);
  machine.bindGameBtn(0, SDL_SCANCODE_X, GameBtns.x);
  machine.bindGameBtn(0, SDL_SCANCODE_Z, GameBtns.y);
  machine.bindGameBtn(0, SDL_SCANCODE_C, GameBtns.y);
  machine.bindGameBtn(0, SDL_SCANCODE_Y, GameBtns.y);
  machine.bindGameBtn(0, SDL_SCANCODE_V, GameBtns.a);
  machine.bindGameBtn(0, SDL_SCANCODE_B, GameBtns.b);
  machine.bindGameBtn(0, SDL_SCANCODE_LCTRL, GameBtns.a);
  machine.bindGameBtn(0, SDL_SCANCODE_SPACE, GameBtns.b);

  machine.bindGameBtn(1, SDL_SCANCODE_RIGHT, GameBtns.right);
  machine.bindGameBtn(1, SDL_SCANCODE_LEFT, GameBtns.left);
  machine.bindGameBtn(1, SDL_SCANCODE_UP, GameBtns.up);
  machine.bindGameBtn(1, SDL_SCANCODE_DOWN, GameBtns.down);
  machine.bindGameBtn(1, SDL_SCANCODE_I, GameBtns.a);
  machine.bindGameBtn(1, SDL_SCANCODE_P, GameBtns.a);
  machine.bindGameBtn(1, SDL_SCANCODE_RETURN, GameBtns.a);
  machine.bindGameBtn(1, SDL_SCANCODE_RCTRL, GameBtns.a);
  machine.bindGameBtn(1, SDL_SCANCODE_O, GameBtns.b);
  machine.bindGameBtn(1, SDL_SCANCODE_L, GameBtns.x);
  machine.bindGameBtn(1, SDL_SCANCODE_BACKSPACE, GameBtns.x);
  machine.bindGameBtn(1, SDL_SCANCODE_K, GameBtns.y);
  machine.bindGameBtn(1, SDL_SCANCODE_SPACE, GameBtns.b);
}
