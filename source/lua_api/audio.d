module lua_api.audio;

import std.string;
import std.conv;
import riverd.lua;
import riverd.lua.types;

import machine;
import program;

/**
  register audio functions for a lua program
*/
void registerFunctions(Program program)
{
  auto lua = program.lua;
  luaL_dostring(lua, "audio = {}");

  /// audio.new(): sampl
  extern (C) int audio_new(lua_State* L) @trusted
  {
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    lua_pushinteger(L, prog.createSample());
    return 1;
  }

  lua_register(lua, "_", &audio_new);
  luaL_dostring(lua, "audio.new = _");

  /// audio.load(filename): sampl
  extern (C) int audio_load(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.readOtherDrives))
        throw new Exception("no permission to read other drives!");
      lua_pushinteger(L, prog.loadSample(prog.actualFile(filename)));
      return 1;
    }
    catch (Exception err)
    {
      lua_pushnil(L);
      return 1;
    }
  }

  lua_register(lua, "_", &audio_load);
  luaL_dostring(lua, "audio.load = _");

  /// audio.save(filename, sampl): success
  extern (C) int audio_save(lua_State* L) @trusted
  {
    auto filename = to!string(lua_tostring(L, 1));
    const smplID = lua_tointeger(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (!prog.isOnOriginDrive(filename) && !prog.hasPermission(Permissions.writeOtherDrives))
        throw new Exception("no permission to write to other drives!");
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      prog.samples[cast(uint) smplID].saveWav(prog.actualFile(filename));
      lua_pushboolean(L, true);
      return 1;
    }
    catch (Exception err)
    {
      lua_pushboolean(L, false);
      return 1;
    }
  }

  lua_register(lua, "_", &audio_save);
  luaL_dostring(lua, "audio.save = _");

  /// audio.play(channel, sampl)
  extern (C) int audio_play(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const smplID = lua_tointeger(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      prog.machine.audio.play(cast(uint) channel, prog.samples[cast(uint) smplID]);
      return 0;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &audio_play);
  luaL_dostring(lua, "audio.play = _");

  /// audio.channelfreq(channel[, freq]): freq
  extern (C) int audio_channelfreq(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const samplerate = lua_tonumber(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (set)
      prog.machine.audio.setFreq(cast(uint) channel, cast(int) samplerate);
    lua_pushinteger(L, prog.machine.audio.getFreq(cast(uint) channel));
    return 1;
  }

  lua_register(lua, "_", &audio_channelfreq);
  luaL_dostring(lua, "audio.channelfreq = _");

  /// audio.channelhead(channel[, pos]): pos
  extern (C) int audio_channelhead(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const pos = lua_tonumber(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (set)
      prog.machine.audio.head[cast(uint) channel] = pos;
    lua_pushnumber(L, prog.machine.audio.head[cast(uint) channel]);
    return 1;
  }

  lua_register(lua, "_", &audio_channelhead);
  luaL_dostring(lua, "audio.channelhead = _");

  /// audio.channelvolume(channel[, volume]): volume
  extern (C) int audio_channelvolume(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const volume = lua_tonumber(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (set)
      prog.machine.audio.setVolume(cast(uint) channel, cast(ubyte) volume);
    lua_pushinteger(L, prog.machine.audio.getVolume(cast(uint) channel));
    return 1;
  }

  lua_register(lua, "_", &audio_channelvolume);
  luaL_dostring(lua, "audio.channelvolume = _");

  /// audio.channelloop(channel[, start, end]): start, end
  extern (C) int audio_channelloop(lua_State* L) @trusted
  {
    const channel = lua_tointeger(L, 1);
    const start = lua_tonumber(L, 2);
    const end = lua_tonumber(L, 3);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    if (set)
      prog.machine.audio.setLoop(cast(uint) channel, cast(uint) start, cast(uint) end);
    lua_pushinteger(L, prog.machine.audio.getLoopStart(cast(uint) channel));
    lua_pushinteger(L, prog.machine.audio.getLoopEnd(cast(uint) channel));
    return 2;
  }

  lua_register(lua, "_", &audio_channelloop);
  luaL_dostring(lua, "audio.channelloop = _");

  /// audio.samplevalue(sampl, pos[, value]): value
  extern (C) int audio_samplevalue(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const pos = lua_tonumber(L, 2);
    const value = lua_tonumber(L, 3);
    const set = 1 - lua_isnoneornil(L, 3);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      if (prog.samples[cast(uint) smplID].data.length <= pos)
        throw new Exception("Invalid position!");
      if (set)
        prog.samples[cast(uint) smplID].data[cast(uint) pos] = cast(byte) value;
      lua_pushinteger(L, prog.samples[cast(uint) smplID].data[cast(uint) pos]);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &audio_samplevalue);
  luaL_dostring(lua, "audio.samplevalue = _");

  /// audio.samplelength(sampl[, length]): length
  extern (C) int audio_samplelength(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const len = lua_tonumber(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      if (set)
      {
        prog.samples[cast(uint) smplID].data.length = cast(uint) len;
      }
      lua_pushinteger(L, prog.samples[cast(uint) smplID].data.length);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &audio_samplelength);
  luaL_dostring(lua, "audio.samplelength = _");

  /// audio.samplefreq(sampl[, freq]): freq
  extern (C) int audio_samplefreq(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const samplerate = lua_tonumber(L, 2);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      if (set)
        prog.samples[cast(uint) smplID].freq = cast(int) samplerate;
      lua_pushinteger(L, prog.samples[cast(uint) smplID].freq);
      return 1;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &audio_samplefreq);
  luaL_dostring(lua, "audio.samplefreq = _");

  /// audio.sampleloop(sampl[, start, end]): start, end
  extern (C) int audio_sampleloop(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    const start = lua_tonumber(L, 2);
    const end = lua_tonumber(L, 3);
    const set = 1 - lua_isnoneornil(L, 2);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      if (set)
      {
        prog.samples[cast(uint) smplID].loopStart = cast(uint) start;
        prog.samples[cast(uint) smplID].loopEnd = cast(uint) end;
      }
      lua_pushinteger(L, prog.samples[cast(uint) smplID].loopStart);
      lua_pushinteger(L, prog.samples[cast(uint) smplID].loopEnd);
      return 2;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &audio_sampleloop);
  luaL_dostring(lua, "audio.sampleloop = _");

  /// audio.forget(sampl)
  extern (C) int audio_forget(lua_State* L) @trusted
  {
    const smplID = lua_tointeger(L, 1);
    lua_getglobal(L, "__program");
    auto prog = cast(Program*) lua_touserdata(L, -1);
    try
    {
      if (smplID >= prog.samples.length || !prog.samples[cast(uint) smplID])
        throw new Exception("Invalid sample!");
      prog.removeSample(cast(uint) smplID);
      return 0;
    }
    catch (Exception err)
    {
      luaL_error(L, toStringz(err.msg));
      return 0;
    }
  }

  lua_register(lua, "_", &audio_forget);
  luaL_dostring(lua, "audio.forget = _");
}
