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
Static function declarations for Lua bindings

This file defines all static function declarations for Lua library bindings.

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2018-2019
+/
module riverd.lua.statfun;

import core.stdc.stdarg;
import riverd.lua.types;


extern(C) @nogc nothrow {

	/** Creates a new thread running in a new, independent state.
	 *
	 * Params:
	 * 	f = The allocator function. Lua does all memory allocation for this
	 * 		state through this function.
	 * 	ud = an opaque pointer that Lua passes to the allocator in every call.
	 *
	 * Returns: `null` if it cannot create the thread or the state
	 * 	(due to lack of memory).
	 *
	 * See_Also: $(REF lua_Alloc, riverd,lua,types)
	 */
	lua_State* lua_newstate(lua_Alloc f, void* ud);


	/** Destroys all objects in the given Lua state.
	 *
	 * Destroys all objects in the given Lua state (calling the corresponding
	 * garbage-collection metamethods, if any) and frees all dynamic memory
	 * used by this state.
	 * In several platforms, you may not need to call this function,
	 * because all resources are naturally released when the host
	 * program ends. On the other hand, long-running programs that create
	 * multiple states, such as daemons or web servers, will probably need
	 * to close states as soon as they are not needed.
	 *
	 * Params:
	 * 	s = Lua state
	 *
	 * See_Also: $(REF lua_State, riverd,lua,types)
	 */
	void lua_close(lua_State* s);


	/** Creates a new thread.
	 *
	 * Creates a new thread and pushes it on the stack. The new thread returned
	 * by this function shares with the original thread its global environment,
	 * but has an independent execution stack.
	 *
	 * Params:
	 * 	s = Lua state
	 *
	 * Returns: a pointer to a lua_State that represents this new thread.
	 *
	 * Note: There is no explicit function to close or to destroy a thread.
	 * 		 Threads are subject to garbage collection, like any Lua object.
	 *
	 * See_Also: $(REF lua_State, riverd,lua,types)
	 */
	lua_State* lua_newthread(lua_State* s);


	/** Sets a new panic function
	 *
	 * Params:
	 * 	s = Lua state
	 * 	func = C lua_State registered function
	 *
	 * Returns: the old panic functio
	 *
	 * Note: The panic function can access the error message at the top of the stack.
	 * 		 If an error happens outside any protected environment, Lua calls a panic
	 * function and then calls exit(EXIT_FAILURE), thus exiting the host application.
	 * Your panic function can avoid this exit by never returning (e.g., doing a long
	 * jump).
	 *
	 * See_Also: $(REF lua_State, riverd,lua,types)
	 * 			 $(REF lua_CFunction, riverd,lua,types)
	 */
	lua_CFunction lua_atpanic(lua_State* s, lua_CFunction func);
	const(lua_Number)* lua_version(lua_State*);
	int lua_absindex(lua_State*, int);
	int lua_gettop(lua_State*);
	void lua_settop(lua_State*, int);
	void lua_pushvalue(lua_State*, int);
	void lua_rotate(lua_State*, int, int);
	void lua_copy(lua_State*, int, int);
	int lua_checkstack(lua_State*, int);
	void lua_xmove(lua_State*, lua_State*, int);
	int lua_isnumber(lua_State*, int);
	int lua_isstring(lua_State*, int);
	int lua_iscfunction(lua_State*, int);
	int lua_isinteger(lua_State*, int);
	int lua_isuserdata(lua_State*, int);
	int lua_type(lua_State*, int);
	const(char)* lua_typename(lua_State*, int);
	lua_Number lua_tonumberx(lua_State*, int, int*);
	lua_Integer lua_tointegerx(lua_State*, int, int*);
	int lua_toboolean(lua_State*, int);
	const(char)* lua_tolstring(lua_State*, int, size_t*);
	size_t lua_rawlen(lua_State*, int);
	lua_CFunction lua_tocfunction(lua_State*, int);
	void* lua_touserdata(lua_State*, int);
	lua_State* lua_tothread(lua_State*, int);
	const(void)* lua_topointer(lua_State*, int);
	void lua_arith(lua_State*, int);
	int lua_rawequal(lua_State*, int, int);
	int lua_compare(lua_State*, int, int, int);
	void lua_pushnil(lua_State*);
	void lua_pushnumber(lua_State*, lua_Number);
	void lua_pushinteger(lua_State*, lua_Integer);
	const(char)* lua_pushlstring(lua_State*, const(char)*, size_t);
	const(char)* lua_pushstring(lua_State*, const(char)*);
	const(char)* lua_pushvfstring(lua_State*, const(char)*, va_list);
	const(char)* lua_pushfstring(lua_State*, const(char)*, ...);
	void lua_pushcclosure(lua_State*, lua_CFunction, int);
	void lua_pushboolean(lua_State*, int);
	void lua_pushlightuserdata(lua_State*, void*);
	int lua_pushthread(lua_State*);
	int lua_getglobal(lua_State*, const(char)*);
	int lua_gettable(lua_State*, int);
	int lua_getfield(lua_State*, int, const(char)*);
	int lua_geti(lua_State*, int, lua_Integer);
	int lua_rawget(lua_State*, int);
	int lua_rawgeti(lua_State*, int, int);
	int lua_rawgetp(lua_State*, int, const(void)*);
	void lua_createtable(lua_State*, int, int);
	void* lua_newuserdata(lua_State*, size_t);
	int lua_getmetatable(lua_State*, int);
	int lua_getuservalue(lua_State*, int);
	void lua_setglobal(lua_State*, const(char)*);
	void lua_settable(lua_State*, int);
	void lua_setfield(lua_State*, int, const(char)*);
	void lua_rawset(lua_State*, int);
	void lua_rawseti(lua_State*, int, lua_Integer);
	void lua_rawsetp(lua_State*, int, const(void)*);
	int lua_setmetatable(lua_State*, int);
	void lua_setuservalue(lua_State*, int);
	void lua_callk(lua_State*, int, int, lua_KContext, lua_KFunction);
	int lua_pcallk(lua_State*, int, int, int, lua_KContext, lua_KFunction);
	int lua_load(lua_State*, lua_Reader, void*, const(char)*, const(char)*);
	int lua_dump(lua_State*, lua_Writer, void*, int);
	int lua_yieldk(lua_State*, int, lua_KContext, lua_KFunction);
	int lua_resume(lua_State*, lua_State*, int);
	int lua_status(lua_State*);
	int lua_isyieldable(lua_State*);
	int lua_gc(lua_State*, int, int);
	int lua_error(lua_State*);
	int lua_next(lua_State*, int);
	void lua_concat(lua_State*, int);
	void lua_len(lua_State*, int);
	size_t lua_stringtonumber(lua_State*, const(char)*);
	lua_Alloc lua_getallocf(lua_State*, void**);
	void lua_setallocf(lua_State*, lua_Alloc, void*);
	int lua_getstack(lua_State*, int, lua_Debug*);
	int lua_getinfo(lua_State*, const(char)*, lua_Debug*);
	const(char)* lua_getlocal(lua_State*, const(lua_Debug)*, int);
	const(char)* lua_setlocal(lua_State*, const(lua_Debug)*, int);
	const(char)* lua_getupvalue(lua_State*, int, int);
	const(char)* lua_setupvalue(lua_State*, int, int);
	void* lua_upvalueid(lua_State*, int, int);
	void lua_upvaluejoin(lua_State*, int, int, int, int);
	void lua_sethook(lua_State*, lua_Hook, int, int);
	lua_Hook lua_gethook(lua_State*);
	int lua_gethookmask(lua_State*);
	int lua_gethookcount(lua_State*);
	void luaL_checkversion_(lua_State*, lua_Number, size_t);
	int luaL_getmetafield(lua_State*, int, const(char)*);
	int luaL_callmeta(lua_State*, int, const(char)*);
	const(char)* luaL_tolstring(lua_State*, int, size_t*);
	int luaL_argerror(lua_State*, int, const(char)*);
	const(char)* luaL_checklstring(lua_State*, int, size_t*);
	const(char)* luaL_optlstring(lua_State*, int, const(char)*, size_t*);
	lua_Number luaL_checknumber(lua_State*, int);
	lua_Number luaL_optnumber(lua_State*, int, lua_Number);
	lua_Integer luaL_checkinteger(lua_State*, int);
	lua_Integer luaL_optinteger(lua_State*, int, lua_Integer);
	void luaL_checkstack(lua_State*, int, const(char)*);
	void luaL_checktype(lua_State*, int, int);
	void luaL_checkany(lua_State*, int);
	int luaL_newmetatable(lua_State*, const(char)*);
	void luaL_setmetatable(lua_State*, const(char)*);
	void* luaL_testudata(lua_State*, int, const(char)*);
	void* luaL_checkudata(lua_State*, int, const(char)*);
	void luaL_where(lua_State*, int);
	int luaL_error(lua_State*, const(char)*, ...);
	int luaL_checkoption(lua_State*, int, const(char)*);
	int luaL_fileresult(lua_State*, int, const(char)*);
	int luaL_execresult(lua_State*, int);
	int luaL_ref(lua_State*, int);
	void luaL_unref(lua_State*, int, int);
	int luaL_loadfilex(lua_State*, const(char)*, const(char)*);
	int luaL_loadbufferx(lua_State*, const(char)*, size_t, const(char)*, const(char)*);
	int luaL_loadstring(lua_State*, const(char)*);
	lua_State* luaL_newstate();
	lua_Integer luaL_len(lua_State*, int);
	const(char)* luaL_gsub(lua_State*, const(char)*, const(char)*, const(char)*);
	void luaL_setfuncs(lua_State*, const luaL_Reg*, int);
	int luaL_getsubtable(lua_State*, int, const(char)*);
	void luaL_traceback(lua_State*, lua_State*, const(char)*, int);
	void luaL_requiref(lua_State*, const(char)*, lua_CFunction, int);
	void luaL_buffinit(lua_State*, luaL_Buffer*);
	char* luaL_prepbuffsize(luaL_Buffer*, size_t);
	void luaL_addlstring(luaL_Buffer*, const(char)*, size_t);
	void luaL_addstring(luaL_Buffer*, const(char)*);
	void luaL_addvalue(luaL_Buffer*);
	void luaL_pushresult(luaL_Buffer*);
	void luaL_pushresultsize(luaL_Buffer*, size_t);
	char* luaL_buffinitsize(lua_State*, luaL_Buffer*, size_t);
	void luaL_pushmodule(lua_State*, const(char)*, int);
	void luaL_openlib(lua_State*, const(char)*, const(luaL_Reg)*, int);
	int luaopen_base(lua_State*);
	int luaopen_coroutine(lua_State*);
	int luaopen_table(lua_State*);
	int luaopen_io(lua_State*);
	int luaopen_os(lua_State*);
	int luaopen_string(lua_State*);
	int luaopen_utf8(lua_State*);
	int luaopen_bit32(lua_State*);
	int luaopen_math(lua_State*);
	int luaopen_debug(lua_State*);
	int luaopen_package(lua_State*);
	void luaL_openlibs(lua_State*);
}
