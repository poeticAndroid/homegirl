/*
                                    __
                                   / _|
  __ _ _   _ _ __ ___  _ __ __ _  | |_ ___  ___ ___
 / _` | | | | '__/ _ \| '__/ _` | |  _/ _ \/ __/ __|
| (_| | |_| | | | (_) | | | (_| | | || (_) \__ \__ \
 \__,_|\__,_|_|  \___/|_|  \__,_| |_| \___/|___/___/

Copyright (C) 1994-2018 Lua.org, PUC-Rio.
Copyright (C) 2018-2019 Aurora Free Open Source Software.
Copyright (C) 2018-2019 Luís Ferreira <luis@aurorafoss.org>

This file is part of the Aurora Free Open Source Software. This
organization promote free and open source software that you can
redistribute and/or modify under the terms of the GNU Lesser General
Public License Version 3 as published by the Free Software Foundation or
(at your option) any later version approved by the Aurora Free Open Source
Software Organization. The license is available in the package root path
as 'LICENSE' file. Please review the following information to ensure the
GNU Lesser General Public License version 3 requirements will be met:
https://www.gnu.org/licenses/lgpl.html .

Alternatively, this file may be used under the terms of the GNU General
Public License version 3 or later as published by the Free Software
Foundation. Please review the following information to ensure the GNU
General Public License requirements will be met:
http://www.gnu.org/licenses/gpl-3.0.html.

NOTE: All products, services or anything associated to trademarks and
service marks used or referenced on this file are the property of their
respective companies/owners or its subsidiaries. Other names and brands
may be claimed as the property of others.

For more info about intellectual property visit: aurorafoss.org or
directly send an email to: contact (at) aurorafoss.org .
*/

/++
Dynamic library loader for Lua bindings

This file defines the dynamic loader for Lua library bindings.

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2018-2019
+/
module riverd.lua.dynload;

import riverd.loader;

public import riverd.lua.dynfun;

version(D_BetterC)
{
	/** Dynamic loader for lua library
	 *
	 * This function load the lua library and bind all dynamic function symbols
	 *
	 * Returns: Returns the loader handler
	 */
	@trusted
	void* dylib_load_lua() {
		version(Windows) void* handle = dylib_load("lua53.dll");
		else version(OSX) void* handle = dylib_load("liblua.5.3.dylib");
		else version(Posix) void* handle = dylib_load("liblua.so.5.3,liblua5.3.so");

		if(handle is null) return null;

		dylib_bindSymbol(handle, cast(void**)&lua_newstate, "lua_newstate");
		dylib_bindSymbol(handle, cast(void**)&lua_close, "lua_close");
		dylib_bindSymbol(handle, cast(void**)&lua_newthread, "lua_newthread");
		dylib_bindSymbol(handle, cast(void**)&lua_atpanic, "lua_atpanic");
		dylib_bindSymbol(handle, cast(void**)&lua_version, "lua_version");
		dylib_bindSymbol(handle, cast(void**)&lua_absindex, "lua_absindex");
		dylib_bindSymbol(handle, cast(void**)&lua_gettop, "lua_gettop");
		dylib_bindSymbol(handle, cast(void**)&lua_settop, "lua_settop");
		dylib_bindSymbol(handle, cast(void**)&lua_pushvalue, "lua_pushvalue");
		dylib_bindSymbol(handle, cast(void**)&lua_rotate, "lua_rotate");
		dylib_bindSymbol(handle, cast(void**)&lua_copy, "lua_copy");
		dylib_bindSymbol(handle, cast(void**)&lua_checkstack, "lua_checkstack");
		dylib_bindSymbol(handle, cast(void**)&lua_xmove, "lua_xmove");
		dylib_bindSymbol(handle, cast(void**)&lua_isnumber, "lua_isnumber");
		dylib_bindSymbol(handle, cast(void**)&lua_isstring, "lua_isstring");
		dylib_bindSymbol(handle, cast(void**)&lua_iscfunction, "lua_iscfunction");
		dylib_bindSymbol(handle, cast(void**)&lua_isinteger, "lua_isinteger");
		dylib_bindSymbol(handle, cast(void**)&lua_isuserdata, "lua_isuserdata");
		dylib_bindSymbol(handle, cast(void**)&lua_type, "lua_type");
		dylib_bindSymbol(handle, cast(void**)&lua_typename, "lua_typename");
		dylib_bindSymbol(handle, cast(void**)&lua_tonumberx, "lua_tonumberx");
		dylib_bindSymbol(handle, cast(void**)&lua_tointegerx, "lua_tointegerx");
		dylib_bindSymbol(handle, cast(void**)&lua_toboolean, "lua_toboolean");
		dylib_bindSymbol(handle, cast(void**)&lua_tolstring, "lua_tolstring");
		dylib_bindSymbol(handle, cast(void**)&lua_rawlen, "lua_rawlen");
		dylib_bindSymbol(handle, cast(void**)&lua_tocfunction, "lua_tocfunction");
		dylib_bindSymbol(handle, cast(void**)&lua_touserdata, "lua_touserdata");
		dylib_bindSymbol(handle, cast(void**)&lua_tothread, "lua_tothread");
		dylib_bindSymbol(handle, cast(void**)&lua_topointer, "lua_topointer");
		dylib_bindSymbol(handle, cast(void**)&lua_arith, "lua_arith");
		dylib_bindSymbol(handle, cast(void**)&lua_rawequal, "lua_rawequal");
		dylib_bindSymbol(handle, cast(void**)&lua_compare, "lua_compare");
		dylib_bindSymbol(handle, cast(void**)&lua_pushnil, "lua_pushnil");
		dylib_bindSymbol(handle, cast(void**)&lua_pushnumber, "lua_pushnumber");
		dylib_bindSymbol(handle, cast(void**)&lua_pushinteger, "lua_pushinteger");
		dylib_bindSymbol(handle, cast(void**)&lua_pushlstring, "lua_pushlstring");
		dylib_bindSymbol(handle, cast(void**)&lua_pushstring, "lua_pushstring");
		dylib_bindSymbol(handle, cast(void**)&lua_pushvfstring, "lua_pushvfstring");
		dylib_bindSymbol(handle, cast(void**)&lua_pushfstring, "lua_pushfstring");
		dylib_bindSymbol(handle, cast(void**)&lua_pushcclosure, "lua_pushcclosure");
		dylib_bindSymbol(handle, cast(void**)&lua_pushboolean, "lua_pushboolean");
		dylib_bindSymbol(handle, cast(void**)&lua_pushlightuserdata, "lua_pushlightuserdata");
		dylib_bindSymbol(handle, cast(void**)&lua_pushthread, "lua_pushthread");
		dylib_bindSymbol(handle, cast(void**)&lua_getglobal, "lua_getglobal");
		dylib_bindSymbol(handle, cast(void**)&lua_gettable, "lua_gettable");
		dylib_bindSymbol(handle, cast(void**)&lua_getfield, "lua_getfield");
		dylib_bindSymbol(handle, cast(void**)&lua_geti, "lua_geti");
		dylib_bindSymbol(handle, cast(void**)&lua_rawget, "lua_rawget");
		dylib_bindSymbol(handle, cast(void**)&lua_rawgeti, "lua_rawgeti");
		dylib_bindSymbol(handle, cast(void**)&lua_rawgetp, "lua_rawgetp");
		dylib_bindSymbol(handle, cast(void**)&lua_createtable, "lua_createtable");
		dylib_bindSymbol(handle, cast(void**)&lua_newuserdata, "lua_newuserdata");
		dylib_bindSymbol(handle, cast(void**)&lua_getmetatable, "lua_getmetatable");
		dylib_bindSymbol(handle, cast(void**)&lua_getuservalue, "lua_getuservalue");
		dylib_bindSymbol(handle, cast(void**)&lua_setglobal, "lua_setglobal");
		dylib_bindSymbol(handle, cast(void**)&lua_settable, "lua_settable");
		dylib_bindSymbol(handle, cast(void**)&lua_setfield, "lua_setfield");
		dylib_bindSymbol(handle, cast(void**)&lua_rawset, "lua_rawset");
		dylib_bindSymbol(handle, cast(void**)&lua_rawseti, "lua_rawseti");
		dylib_bindSymbol(handle, cast(void**)&lua_rawsetp, "lua_rawsetp");
		dylib_bindSymbol(handle, cast(void**)&lua_setmetatable, "lua_setmetatable");
		dylib_bindSymbol(handle, cast(void**)&lua_setuservalue, "lua_setuservalue");
		dylib_bindSymbol(handle, cast(void**)&lua_callk, "lua_callk");
		dylib_bindSymbol(handle, cast(void**)&lua_pcallk, "lua_pcallk");
		dylib_bindSymbol(handle, cast(void**)&lua_load, "lua_load");
		dylib_bindSymbol(handle, cast(void**)&lua_dump, "lua_dump");
		dylib_bindSymbol(handle, cast(void**)&lua_yieldk, "lua_yieldk");
		dylib_bindSymbol(handle, cast(void**)&lua_resume, "lua_resume");
		dylib_bindSymbol(handle, cast(void**)&lua_status, "lua_status");
		dylib_bindSymbol(handle, cast(void**)&lua_isyieldable, "lua_isyieldable");
		dylib_bindSymbol(handle, cast(void**)&lua_gc, "lua_gc");
		dylib_bindSymbol(handle, cast(void**)&lua_error, "lua_error");
		dylib_bindSymbol(handle, cast(void**)&lua_next, "lua_next");
		dylib_bindSymbol(handle, cast(void**)&lua_concat, "lua_concat");
		dylib_bindSymbol(handle, cast(void**)&lua_len, "lua_len");
		dylib_bindSymbol(handle, cast(void**)&lua_stringtonumber, "lua_stringtonumber");
		dylib_bindSymbol(handle, cast(void**)&lua_getallocf, "lua_getallocf");
		dylib_bindSymbol(handle, cast(void**)&lua_setallocf, "lua_setallocf");
		dylib_bindSymbol(handle, cast(void**)&lua_getstack, "lua_getstack");
		dylib_bindSymbol(handle, cast(void**)&lua_getinfo, "lua_getinfo");
		dylib_bindSymbol(handle, cast(void**)&lua_getlocal, "lua_getlocal");
		dylib_bindSymbol(handle, cast(void**)&lua_setlocal, "lua_setlocal");
		dylib_bindSymbol(handle, cast(void**)&lua_getupvalue, "lua_getupvalue");
		dylib_bindSymbol(handle, cast(void**)&lua_setupvalue, "lua_setupvalue");
		dylib_bindSymbol(handle, cast(void**)&lua_upvalueid, "lua_upvalueid");
		dylib_bindSymbol(handle, cast(void**)&lua_upvaluejoin, "lua_upvaluejoin");
		dylib_bindSymbol(handle, cast(void**)&lua_sethook, "lua_sethook");
		dylib_bindSymbol(handle, cast(void**)&lua_gethook, "lua_gethook");
		dylib_bindSymbol(handle, cast(void**)&lua_gethookmask, "lua_gethookmask");
		dylib_bindSymbol(handle, cast(void**)&lua_gethookcount, "lua_gethookcount");
		dylib_bindSymbol(handle, cast(void**)&luaL_checkversion_, "luaL_checkversion_");
		dylib_bindSymbol(handle, cast(void**)&luaL_getmetafield, "luaL_getmetafield");
		dylib_bindSymbol(handle, cast(void**)&luaL_callmeta, "luaL_callmeta");
		dylib_bindSymbol(handle, cast(void**)&luaL_tolstring, "luaL_tolstring");
		dylib_bindSymbol(handle, cast(void**)&luaL_argerror, "luaL_argerror");
		dylib_bindSymbol(handle, cast(void**)&luaL_checklstring, "luaL_checklstring");
		dylib_bindSymbol(handle, cast(void**)&luaL_optlstring, "luaL_optlstring");
		dylib_bindSymbol(handle, cast(void**)&luaL_checknumber, "luaL_checknumber");
		dylib_bindSymbol(handle, cast(void**)&luaL_optnumber, "luaL_optnumber");
		dylib_bindSymbol(handle, cast(void**)&luaL_checkinteger, "luaL_checkinteger");
		dylib_bindSymbol(handle, cast(void**)&luaL_optinteger, "luaL_optinteger");
		dylib_bindSymbol(handle, cast(void**)&luaL_checkstack, "luaL_checkstack");
		dylib_bindSymbol(handle, cast(void**)&luaL_checktype, "luaL_checktype");
		dylib_bindSymbol(handle, cast(void**)&luaL_checkany, "luaL_checkany");
		dylib_bindSymbol(handle, cast(void**)&luaL_newmetatable, "luaL_newmetatable");
		dylib_bindSymbol(handle, cast(void**)&luaL_setmetatable, "luaL_setmetatable");
		dylib_bindSymbol(handle, cast(void**)&luaL_testudata, "luaL_testudata");
		dylib_bindSymbol(handle, cast(void**)&luaL_checkudata, "luaL_checkudata");
		dylib_bindSymbol(handle, cast(void**)&luaL_where, "luaL_where");
		dylib_bindSymbol(handle, cast(void**)&luaL_error, "luaL_error");
		dylib_bindSymbol(handle, cast(void**)&luaL_checkoption, "luaL_checkoption");
		dylib_bindSymbol(handle, cast(void**)&luaL_fileresult, "luaL_fileresult");
		dylib_bindSymbol(handle, cast(void**)&luaL_execresult, "luaL_execresult");
		dylib_bindSymbol(handle, cast(void**)&luaL_ref, "luaL_ref");
		dylib_bindSymbol(handle, cast(void**)&luaL_unref, "luaL_unref");
		dylib_bindSymbol(handle, cast(void**)&luaL_loadfilex, "luaL_loadfilex");
		dylib_bindSymbol(handle, cast(void**)&luaL_loadbufferx, "luaL_loadbufferx");
		dylib_bindSymbol(handle, cast(void**)&luaL_loadstring, "luaL_loadstring");
		dylib_bindSymbol(handle, cast(void**)&luaL_newstate, "luaL_newstate");
		dylib_bindSymbol(handle, cast(void**)&luaL_len, "luaL_len");
		dylib_bindSymbol(handle, cast(void**)&luaL_gsub, "luaL_gsub");
		dylib_bindSymbol(handle, cast(void**)&luaL_setfuncs, "luaL_setfuncs");
		dylib_bindSymbol(handle, cast(void**)&luaL_getsubtable, "luaL_getsubtable");
		dylib_bindSymbol(handle, cast(void**)&luaL_traceback, "luaL_traceback");
		dylib_bindSymbol(handle, cast(void**)&luaL_requiref, "luaL_requiref");
		dylib_bindSymbol(handle, cast(void**)&luaL_buffinit, "luaL_buffinit");
		dylib_bindSymbol(handle, cast(void**)&luaL_prepbuffsize, "luaL_prepbuffsize");
		dylib_bindSymbol(handle, cast(void**)&luaL_addlstring, "luaL_addlstring");
		dylib_bindSymbol(handle, cast(void**)&luaL_addstring, "luaL_addstring");
		dylib_bindSymbol(handle, cast(void**)&luaL_addvalue, "luaL_addvalue");
		dylib_bindSymbol(handle, cast(void**)&luaL_pushresult, "luaL_pushresult");
		dylib_bindSymbol(handle, cast(void**)&luaL_pushresultsize, "luaL_pushresultsize");
		dylib_bindSymbol(handle, cast(void**)&luaL_buffinitsize, "luaL_buffinitsize");
		dylib_bindSymbol(handle, cast(void**)&luaL_pushmodule, "luaL_pushmodule");
		dylib_bindSymbol(handle, cast(void**)&luaL_openlib, "luaL_openlib");
		dylib_bindSymbol(handle, cast(void**)&luaopen_base, "luaopen_base");
		dylib_bindSymbol(handle, cast(void**)&luaopen_coroutine, "luaopen_coroutine");
		dylib_bindSymbol(handle, cast(void**)&luaopen_table, "luaopen_table");
		dylib_bindSymbol(handle, cast(void**)&luaopen_io, "luaopen_io");
		dylib_bindSymbol(handle, cast(void**)&luaopen_os, "luaopen_os");
		dylib_bindSymbol(handle, cast(void**)&luaopen_string, "luaopen_string");
		dylib_bindSymbol(handle, cast(void**)&luaopen_utf8, "luaopen_utf8");
		dylib_bindSymbol(handle, cast(void**)&luaopen_bit32, "luaopen_bit32");
		dylib_bindSymbol(handle, cast(void**)&luaopen_math, "luaopen_math");
		dylib_bindSymbol(handle, cast(void**)&luaopen_debug, "luaopen_debug");
		dylib_bindSymbol(handle, cast(void**)&luaopen_package, "luaopen_package");
		dylib_bindSymbol(handle, cast(void**)&luaL_openlibs, "luaL_openlibs");

		return handle;
	}
}
else
{
	version(Windows) private enum string[] _lua_libs = ["lua53.dll"];
	else version(OSX) private enum string[] _lua_libs = ["liblua.5.3.dylib"];
	else version(Posix) private enum string[] _lua_libs = ["liblua.so.5.3", "liblua5.3.so"];

	mixin(DylibLoaderBuilder!("Lua", _lua_libs, riverd.lua.dynfun));
}

@system unittest {
	void* lua_handle = dylib_load_lua();
	assert(dylib_is_loaded(lua_handle));

	dylib_unload(lua_handle);
}
