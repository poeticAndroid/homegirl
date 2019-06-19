module lua_api.audio;

import std.string;
import riverd.lua;
import riverd.lua.types;

import program;

/**
  register audio functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "audio = {}");

  /// audio.createsample(): id
  extern (C) int audio_createsample(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createSample());
    return 1;
  }

  lua_register(lua, "_", &audio_createsample);
  luaL_dostring(lua, "audio.createsample = _");

  /// audio.loadsample(filename): id
  extern (C) int audio_loadsample(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, -1));
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.loadSample(cast(string) filename));
    return 1;
  }

  lua_register(lua, "_", &audio_loadsample);
  luaL_dostring(lua, "audio.loadsample = _");

  /// audio.playsample(channel, smplID)
  extern (C) int audio_playsample(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, -2);
    const smplID = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
    {
      lua_pushstring(L, "Invalid sample!");
      lua_error(L);
      return 0;
    }
    prog.machine.audio.play(cast(uint) channel, prog.samples[cast(uint) smplID]);
    return 0;
  }

  lua_register(lua, "_", &audio_playsample);
  luaL_dostring(lua, "audio.playsample = _");

  /// audio.setsamplerate(channel, samplerate)
  extern (C) int audio_setsamplerate(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, -2);
    const samplerate = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.audio.setFreq(cast(uint) channel, cast(int) samplerate);
    return 0;
  }

  lua_register(lua, "_", &audio_setsamplerate);
  luaL_dostring(lua, "audio.setsamplerate = _");

  /// audio.setvolume(channel, volume)
  extern (C) int audio_setvolume(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, -2);
    const volume = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.audio.setVolume(cast(uint) channel, cast(ubyte) volume);
    return 0;
  }

  lua_register(lua, "_", &audio_setvolume);
  luaL_dostring(lua, "audio.setvolume = _");

  /// audio.setsampleloop(channel, start, end)
  extern (C) int audio_setsampleloop(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, -3);
    const start = lua_tonumber(L, -2);
    const end = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.audio.setLoop(cast(uint) channel, cast(uint) start, cast(uint) end);
    return 0;
  }

  lua_register(lua, "_", &audio_setsampleloop);
  luaL_dostring(lua, "audio.setsampleloop = _");

  /// audio.editsample(smplID, pos, value)
  extern (C) int audio_editsample(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, -3);
    const pos = lua_tonumber(L, -2);
    const value = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
    {
      lua_pushstring(L, "Invalid sample!");
      lua_error(L);
      return 0;
    }
    if (prog.samples[cast(uint) smplID].data.length <= pos)
      prog.samples[cast(uint) smplID].data.length = cast(uint) pos + 1;
    prog.samples[cast(uint) smplID].data[cast(uint) pos] = cast(byte) value;
    return 0;
  }

  lua_register(lua, "_", &audio_editsample);
  luaL_dostring(lua, "audio.editsample = _");

  /// audio.editsamplerate(smplID, samplerate)
  extern (C) int audio_editsamplerate(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, -2);
    const samplerate = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
    {
      lua_pushstring(L, "Invalid sample!");
      lua_error(L);
      return 0;
    }
    prog.samples[cast(uint) smplID].freq = cast(int) samplerate;
    return 0;
  }

  lua_register(lua, "_", &audio_editsamplerate);
  luaL_dostring(lua, "audio.editsamplerate = _");

  /// audio.editsampleloop(smplID, start, end)
  extern (C) int audio_editsampleloop(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, -3);
    const start = lua_tonumber(L, -2);
    const end = lua_tonumber(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
    {
      lua_pushstring(L, "Invalid sample!");
      lua_error(L);
      return 0;
    }
    prog.samples[cast(uint) smplID].loopStart = cast(uint) start;
    prog.samples[cast(uint) smplID].loopEnd = cast(uint) end;
    return 0;
  }

  lua_register(lua, "_", &audio_editsampleloop);
  luaL_dostring(lua, "audio.editsampleloop = _");

  /// audio.forgetsample(smplID)
  extern (C) int audio_forgetsample(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, -1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeSample(cast(uint) smplID);
    return 0;
  }

  lua_register(lua, "_", &audio_forgetsample);
  luaL_dostring(lua, "audio.forgetsample = _");
}
