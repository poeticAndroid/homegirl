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

  /// audio.new(): id
  extern (C) int audio_create(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createSample());
    return 1;
  }

  lua_register(lua, "_", &audio_create);
  luaL_dostring(lua, "audio.new = _");

  /// audio.load(filename): id
  extern (C) int audio_load(lua_State* L) @trusted
  {
    auto filename = fromStringz(lua_tostring(L, 1));
    //Get the pointer
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.loadSample(cast(string) filename));
    return 1;
  }

  lua_register(lua, "_", &audio_load);
  luaL_dostring(lua, "audio.load = _");

  /// audio.play(channel, smplID)
  extern (C) int audio_play(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const smplID = lua_tointeger(L, 2);
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

  lua_register(lua, "_", &audio_play);
  luaL_dostring(lua, "audio.play = _");

  /// audio.setrate(channel, samplerate)
  extern (C) int audio_setrate(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const samplerate = lua_tonumber(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.audio.setFreq(cast(uint) channel, cast(int) samplerate);
    return 0;
  }

  lua_register(lua, "_", &audio_setrate);
  luaL_dostring(lua, "audio.setrate = _");

  /// audio.setvolume(channel, volume)
  extern (C) int audio_setvolume(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const volume = lua_tonumber(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.audio.setVolume(cast(uint) channel, cast(ubyte) volume);
    return 0;
  }

  lua_register(lua, "_", &audio_setvolume);
  luaL_dostring(lua, "audio.setvolume = _");

  /// audio.setloop(channel, start, end)
  extern (C) int audio_setloop(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const start = lua_tonumber(L, 2);
    const end = lua_tonumber(L, 3);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.machine.audio.setLoop(cast(uint) channel, cast(uint) start, cast(uint) end);
    return 0;
  }

  lua_register(lua, "_", &audio_setloop);
  luaL_dostring(lua, "audio.setloop = _");

  /// audio.edit(smplID, pos, value)
  extern (C) int audio_edit(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const pos = lua_tonumber(L, 2);
    const value = lua_tonumber(L, 3);
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

  lua_register(lua, "_", &audio_edit);
  luaL_dostring(lua, "audio.edit = _");

  /// audio.editrate(smplID, samplerate)
  extern (C) int audio_editrate(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const samplerate = lua_tonumber(L, 2);
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

  lua_register(lua, "_", &audio_editrate);
  luaL_dostring(lua, "audio.editrate = _");

  /// audio.editloop(smplID, start, end)
  extern (C) int audio_editloop(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const start = lua_tonumber(L, 2);
    const end = lua_tonumber(L, 3);
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

  lua_register(lua, "_", &audio_editloop);
  luaL_dostring(lua, "audio.editloop = _");

  /// audio.forget(smplID)
  extern (C) int audio_forget(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    prog.removeSample(cast(uint) smplID);
    return 0;
  }

  lua_register(lua, "_", &audio_forget);
  luaL_dostring(lua, "audio.forget = _");
}
