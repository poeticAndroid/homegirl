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
Type definitions for Lua bindings

This file defines all types for Lua library bindings.

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2018-2019
+/
module riverd.lua.types;

import core.stdc.stdarg;


/** Lua 32-bit integer type */
alias LUA_INT32 = int;


/** Unsigned type of the integral basic types
 *
 * Represents a type that is large enough to represent an offset into all
 * addressable memory
 *
 * See_Also: $(LREF LUAI_MEM)
 */
alias LUAI_UMEM = size_t;


/** Signed integral basic type with the same size as LUAI_UMEM
 *
 * See_Also: $(LREF LUAI_UMEM)
  */
alias LUAI_MEM = ptrdiff_t;


/** 64-bit floating point type */
alias LUAI_UACNUMBER = double;


enum {
	LUA_NUMBER_SCAN = "%lf", /** scan formatter for lua numbers */
	LUA_NUMBER_FMT = "%.14g", /** formatter for lua numbers */
}


/** Limits the size of the Lua stack.
 *
 * Its only purpose is to stop Lua from consuming unlimited stack
 * space (and to reserve some numbers for pseudo-indices).
*/
enum LUAI_MAXSTACK = 1_000_000;


/** Defines the size of a raw memory area.
 *
 * Associated with a Lua state with very fast access.
 */
enum LUA_EXTRASPACE = (void*).sizeof;


/** Mininum Major Lua version which this binding is compatible with
 *
 * See_Also: $(LREF LUA_VERSION_MINOR)
 */
enum LUA_VERSION_MAJOR ="5";


/** Minimum Minor Lua version which this binding is compatible with
 *
 * See_Also: $(LREF LUA_VERSION_MAJOR)
 */
enum LUA_VERSION_MINOR ="3";


/** Minimum Lua version number which this binding is compatible with
 *
 * See_Also: $(LREF LUA_VERSION)
 */
enum LUA_VERSION_NUM = 503;


/** Minimum Lua release version which this binding is compatible with
 *
 * See_Also: $(LREF LUA_RELEASE)
 */
enum LUA_VERSION_RELEASE = "0";


/** Minimum Lua version which this binding is compatible with
 *
 * See_Also: $(LREF LUA_VERSION_NUM)
 */
enum LUA_VERSION = "Lua " ~ LUA_VERSION_MAJOR ~ "." ~ LUA_VERSION_MINOR;


/** Minimum Lua release which this binding is compatible with
 *
 * See_Also: $(LREF LUA_VERSION_RELEASE)
 */
enum LUA_RELEASE = LUA_VERSION ~ "." ~ LUA_VERSION_RELEASE;


/** Lua copyright statement
 *
 * See_Also: $(LREF LUA_AUTHORS)
 */
enum LUA_COPYRIGHT = LUA_RELEASE ~ "  Copyright (C) 1994-2018 Lua.org, PUC-Rio";


/** Lua authors
 *
 * See_Also: $(LREF LUA_COPYRIGHT)
 */
enum LUA_AUTHORS = "R. Ierusalimschy, L. H. de Figueiredo, W. Celes";


/** mark for precompiled code ('<esc>Lua') */
enum LUA_SIGNATURE = "\x1bLua";


/** option for multiple returns in 'lua_pcall' and 'lua_call' */
enum LUA_MULTRET = -1;


/** The minimum valid index */
enum LUA_REGISTRYINDEX = -LUAI_MAXSTACK - 1_000;


/** Pseudo-indices
 *
 * See_Also: $(LREF LUA_REGISTRYINDEX)
 */
int lua_upvalueindex(int i) nothrow {
	return LUA_REGISTRYINDEX - i;
}


/** Thread status */
enum {
	LUA_OK			= 0, /** no errors */
	LUA_YIELD		= 1, /** yield thread status */
	LUA_ERRRUN		= 2, /** runtime error */
	LUA_ERRSYNTAX	= 3, /** syntax error during precompilation */
	LUA_ERRMEM		= 4, /** memory allocation (out-of-memory) error */
	LUA_ERRGCMM		= 5, /** error while running a __gc metamethod. */
	LUA_ERRERR		= 6, /** error while running the message handler. */
}


/** Lua thread state.
 *
 * Indirectly, through the thread, it also refers to the Lua
 * state associated to the thread.
 */
struct lua_State;


/** Lua types */
enum
{
	LUA_TNONE			= -1, /** non-valid (but acceptable) index. */
	LUA_TNIL			= 0, /** Lua NIL type */
	LUA_TBOOLEAN		= 1, /** boolean type */
	LUA_TLIGHTUSERDATA	= 2, /** light user data type */
	LUA_TNUMBER			= 3, /** number type */
	LUA_TSTRING			= 4, /** string type */
	LUA_TTABLE			= 5, /** table type */
	LUA_TFUNCTION		= 6, /** function type */
	LUA_TUSERDATA		= 7, /** user data type */
	LUA_TTHREAD			= 8, /** thread type */
	LUA_NUMTAGS			= 9, /** number tags */
}


/** minimum Lua stack available to a C function */
enum LUA_MINSTACK = 20;


/** predefined values in the registry */
enum
{
	LUA_RIDX_MAINTHREAD	= 1, /** the main thread registry index of the state */
	LUA_RIDX_GLOBALS	= 2, /** the global environment registry index */
	LUA_RIDX_LAST		= LUA_RIDX_GLOBALS, /** the last registery index */
}


alias lua_Number = double; /** type of numbers in Lua */
alias lua_Integer = long; /** type for integer functions */
alias lua_Unsigned = uint; /** type for integer functions */
alias lua_KContext = ptrdiff_t; /** type for continuation-function contexts */


/** alias to lua_Number
 *
 * See_Also: $(LREF lua_Number)
 */
alias LUA_NUMBER = lua_Number;


/** alias to lua_Integer
 *
 * See_Also: $(LREF lua_Integer)
 */
alias LUA_INTEGER = lua_Integer;


/** alias to lua_Unsigned
 *
 * See_Also: $(LREF lua_Unsigned)
 */
alias LUA_UNSIGNED = lua_Unsigned;


/** alias to lua_KContext
 *
 * See_Also: $(LREF lua_KContext)
 */
alias LUA_KCONTEXT = lua_KContext;


extern(C) {

	/** Type for C functions registered with Lua */
	alias lua_CFunction = int function(lua_State*) @trusted;


	/** Type for continuation functions */
	alias lua_KFunction = int function(lua_State*, int, lua_KContext);


	/** Type for functions that read/write blocks when loading/dumping Lua chunks */
	alias lua_Reader = const(char)* function(lua_State*, void*, size_t*);

	/// ditto
	alias lua_Writer = int function(lua_State*, const(void)*, size_t, void*);


	/** Type for memory-allocation functions */
	alias lua_Alloc = void* function(void*, void*, size_t, size_t);
}


/** Comparison annd arithmetic functions */
enum {
	LUA_OPADD = 0,
	LUA_OPSUB = 1,
	LUA_OPMUL = 2,
	LUA_OPMOD = 3,
	LUA_OPPOW = 4,
	LUA_OPDIV = 5,
	LUA_OPIDIV = 6,
	LUA_OPBAND = 7,
	LUA_OPBOR = 8,
	LUA_OPBXOR = 9,
	LUA_OPSHL = 10,
	LUA_OPSHR = 11,
	LUA_OPUNM = 12,
	LUA_OPBNOT = 13,
}


enum {
	/// stfu
	LUA_OPEQ = 0, ///
	LUA_OPLT = 1, ///
	LUA_OPLE = 2, ///
}


/** garbage-collection function and options */
enum {
	LUA_GCSTOP = 0, /** stops the garbage collector */
	LUA_GCRESTART = 1, /** restarts the garbage collector */
	LUA_GCCOLLECT = 2, /** performs a full garbage-collection cycle */

	/** returns the current amount of memory (in Kbytes) in use by Lua */
	LUA_GCCOUNT = 3,

	/** returns the remainder of dividing the current amount of bytes of
	 * memory in use by Lua by 1024
	 */
	LUA_GCCOUNTB = 4,

	/** performs an incremental step of garbage collection. The step "size"
	 * is controlled by data (larger values mean more steps) in a non-specified
	 * way. If you want to control the step size you must experimentally tune
	 * the value of data. The function returns 1 if the step finished a
	 * garbage-collection cycle
	 */
	LUA_GCSTEP = 5,

	/** sets data as the new value for the pause of the collector.
	 * The function returns the previous value of the pause
	 */
	LUA_GCSETPAUSE = 6,

	/** sets data as the new value for the step multiplier of the collector.
	 * The function returns the previous value of the step multiplier.
	 */
	LUA_GCSETSTEPMUL = 7,

	/// stfu
	LUA_GCISRUNNING = 9, ///
}


/** Event codes */
enum {
	LUA_HOOKCALL = 0, /** call hook */
	LUA_HOOKRET = 1, /** return hook */
	LUA_HOOKLINE = 2, /** line hook */
	LUA_HOOKCOUNT = 3, /** count hook */
	LUA_HOOKTAILCALL = 4, /** tail call hook */
}


/** Event masks */
enum {
	LUA_MASKCALL = 1 << LUA_HOOKCALL, /** call mask */
	LUA_MASKRET = 1 << LUA_HOOKRET, /** return mask */
	LUA_MASKLINE = 1 << LUA_HOOKLINE, /** line mask */
	LUA_MASKCOUNT = 1 << LUA_HOOKCOUNT, /** count mask */
}

/** Max debug function description
 *
 * Gives the maximum size for the description of the source
 * of a function in debug information.
 */
enum LUA_IDSIZE = 60;

struct lua_Debug {
	int event;
	const char* name;
	const char* namewhat;
	const char* what;
	const char* source;
	int currentline;
	int linedefined;
	int lastlinedefined;
	byte nups;
	byte params;
	char isvararg;
	char istailcall;
	char[LUA_IDSIZE] short_src;

private:
	struct CallInfo;
	CallInfo* i_ci; /* active function */
}

extern(C) nothrow alias lua_Hook = void function(lua_State*, lua_Debug*);


struct luaL_Reg
{
	const(char)* name;
	lua_CFunction func;
}

enum LUAL_NUMSIZES = (lua_Integer.sizeof * 16) + lua_Number.sizeof;

enum LUA_NOREF = -2;
enum int LUA_REFNIL = -1;

struct luaL_Buffer {
	char* b;
	size_t size;
	size_t n;
	lua_State* L;
	char[] initb;
}

struct luaL_Stream;

enum : string {
	LUA_COLIBNAME = "coroutine",
	LUA_TABLIBNAME = "table",
	LUA_IOLIBNAME = "io",
	LUA_OSLIBNAME = "os",
	LUA_STRLIBNAME = "string",
	LUA_UTF8LIBNAME = "utf8",
	LUA_BITLIBNAME = "bit32",
	LUA_MATHLIBNAME = "math",
	LUA_DBLIBNAME = "debug",
	LUA_LOADLIBNAME = "package",
}

version(RiverD_Lua_Static) {
	import riverd.lua.statfun;
} else {
	import riverd.lua.dynfun;
}

@nogc nothrow {
	ptrdiff_t lua_getextraspace(lua_State* L) {
		return cast(ptrdiff_t)(cast(void*)L - LUA_EXTRASPACE);
	}

	void lua_call(lua_State* L, int nargs, int nresults) {
		lua_callk(L, nargs, nresults, 0, null);
	}

	int lua_pcall(lua_State* L, int nargs, int nresults, int errfunc) {
		return lua_pcallk(L, nargs, nresults, errfunc, 0, null);
	}

	int lua_yield(lua_State* L, int nresults) {
		return lua_yieldk(L, nresults, 0, null);
	}

	lua_Number lua_tonumber(lua_State* L, int i) {
		return lua_tonumberx(L, i, null);
	}

	lua_Integer lua_tointeger(lua_State* L, int i) {
		return lua_tointegerx(L, i, null);
	}

	void lua_pop(lua_State* L, int idx) {
		lua_settop(L, (-idx)-1);
	}

	void lua_newtable(lua_State* L) {
		lua_createtable(L, 0, 0);
	}

	void lua_register(lua_State* L, const(char)* n, lua_CFunction f) {
		lua_pushcfunction(L, f);
		lua_setglobal(L, n);
	}

	void lua_pushcfunction(lua_State* L, lua_CFunction f) {
		lua_pushcclosure(L, f, 0);
	}

	bool lua_isfunction(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TFUNCTION;
	}

	bool lua_istable(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TTABLE;
	}

	bool lua_islightuserdata(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TLIGHTUSERDATA;
	}

	bool lua_isnil(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TNIL;
	}

	bool lua_isboolean(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TBOOLEAN;
	}

	bool lua_isthread(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TTHREAD;
	}

	bool lua_isnone(lua_State* L, int idx) {
		return lua_type(L, idx) == LUA_TNONE;
	}

	bool lua_isnoneornil(lua_State* L, int idx) {
		return lua_type(L, idx) <= 0;
	}

	const(char)* lua_pushliteral(lua_State* L, string s) {
		return lua_pushstring(L, s.ptr);
	}

	void lua_pushglobaltable(lua_State* L) {
		lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
	}

	const(char)* lua_tostring(lua_State* L, int idx) {
		return lua_tolstring(L, idx, null);
	}

	void lua_insert(lua_State* L, int idx) {
		lua_rotate(L, idx, 1);
	}

	void lua_remove(lua_State* L, int idx) {
		lua_rotate(L, idx, -1);
		lua_pop(L, 1);
	}

	void lua_replace(lua_State* L, int idx) {
		lua_copy(L, -1, idx);
		lua_pop(L, 1);
	}

	void luaL_checkversion(lua_State* L) {
		luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES);
	}

	int luaL_loadfile(lua_State* L, const(char)* f) {
		return luaL_loadfilex(L, f, null);
	}

	void luaL_newlibtable(lua_State* L, const(luaL_Reg)[] l) {
		lua_createtable(L, 0, cast(int)(l.length) - 1);
	}

	void luaL_newlib(lua_State* L, luaL_Reg[] l) {
		luaL_checkversion(L);
		luaL_newlibtable(L, l);
		luaL_setfuncs(L, l.ptr, 0);
	}

	const(char)* luaL_checkstring(lua_State* L, int n) {
		return luaL_checklstring(L, n, null);
	}

	const(char)* luaL_optstring(lua_State* L, int n, const(char)* d) {
		return luaL_optlstring(L, n, d, null);
	}


	/**
	 *
	 * Returns: the name of the type of the value at the given index.
	 */
	pragma(inline)
	const(char)* luaL_typename(lua_State* L, int i) {
		return lua_typename(L, lua_type(L,i));
	}


	/** Loads and runs the given file.
	*
	* It is definend by a macro.
	*
	* Returns: 0 if there are no errors or 1 in case of errors.
	*/
	pragma(inline)
	int luaL_dofile(lua_State* L, const(char)* fn) {
		luaL_loadfile(L, fn);
		return lua_pcall(L, 0, LUA_MULTRET, 0);
	}


	/** Loads and runs the given string.
	 *
	 * It is defined by a macro.
	 *
	 * Returns: false if there are no errors or true in case of errors.
	 */
	pragma(inline)
	int luaL_dostring(lua_State* L, const(char)* s) {
		luaL_loadstring(L, s);
		return lua_pcall(L, 0, LUA_MULTRET, 0);
	}


	/** Pushes onto the stack the metatable associated with name tname in the registry.
	 *
	 * Returns: the type of the pushed value (nil if there is no metatable associated with that name)
	 *
	 * See_Also: $(LREF luaL_newmetatable)
	 */
	pragma(inline)
	void luaL_getmetatable(lua_State* L, const(char)* n) {
		lua_getfield(L, LUA_REGISTRYINDEX, n);
	}


	/** Equivalent to luaL_loadbufferx with mode equal to NULL. */
	pragma(inline)
	int luaL_loadbuffer(lua_State* L, const(char)* s, size_t sz, const(char)* n) {
		return luaL_loadbufferx(L, s, sz, n, null);
	}

}


extern(C) @nogc nothrow {
	alias da_lua_newstate = lua_State* function(lua_Alloc, void*); ///
	alias da_lua_close = void function(lua_State*); ///
	alias da_lua_newthread = lua_State* function(lua_State*); ///
	alias da_lua_atpanic = lua_CFunction function(lua_State*, lua_CFunction); ///
	alias da_lua_version = const(lua_Number)* function(lua_State*); ///
	alias da_lua_absindex = int function(lua_State*, int); ///
	alias da_lua_gettop = int function(lua_State*); ///
	alias da_lua_settop = void function(lua_State*, int); ///
	alias da_lua_pushvalue = void function(lua_State*, int); ///
	alias da_lua_rotate = void function(lua_State*, int, int); ///
	alias da_lua_copy = void function(lua_State*, int, int); ///
	alias da_lua_checkstack = int function(lua_State*, int); ///
	alias da_lua_xmove = void function(lua_State*, lua_State*, int); ///
	alias da_lua_isnumber = int function(lua_State*, int); ///
	alias da_lua_isstring = int function(lua_State*, int); ///
	alias da_lua_iscfunction = int function(lua_State*, int); ///
	alias da_lua_isinteger = int function(lua_State*, int); ///
	alias da_lua_isuserdata = int function(lua_State*, int); ///
	alias da_lua_type = int function(lua_State*, int); ///
	alias da_lua_typename = const(char)* function(lua_State*, int); ///
	alias da_lua_tonumberx = lua_Number function(lua_State*, int, int*); ///
	alias da_lua_tointegerx = lua_Integer function(lua_State*, int, int*); ///
	alias da_lua_toboolean = int function(lua_State*, int); ///
	alias da_lua_tolstring = const(char)* function(lua_State*, int, size_t*); ///
	alias da_lua_rawlen = size_t function(lua_State*, int); ///
	alias da_lua_tocfunction = lua_CFunction function(lua_State*, int); ///
	alias da_lua_touserdata = void* function(lua_State*, int); ///
	alias da_lua_tothread = lua_State* function(lua_State*, int); ///
	alias da_lua_topointer = const(void)* function(lua_State*, int); ///
	alias da_lua_arith = void function(lua_State*, int); ///
	alias da_lua_rawequal = int function(lua_State*, int, int); ///
	alias da_lua_compare = int function(lua_State*, int, int, int); ///
	alias da_lua_pushnil = void function(lua_State*); ///
	alias da_lua_pushnumber = void function(lua_State*, lua_Number); ///
	alias da_lua_pushinteger = void function(lua_State*, lua_Integer); ///
	alias da_lua_pushlstring = const(char)* function(lua_State*, const(char)*, size_t); ///
	alias da_lua_pushstring = const(char)* function(lua_State*, const(char)*); ///
	alias da_lua_pushvfstring = const(char)* function(lua_State*, const(char)*, va_list); ///
	alias da_lua_pushfstring = const(char)* function(lua_State*, const(char)*, ...); ///
	alias da_lua_pushcclosure = void function(lua_State*, lua_CFunction, int); ///
	alias da_lua_pushboolean = void function(lua_State*, int); ///
	alias da_lua_pushlightuserdata = void function(lua_State*, void*); ///
	alias da_lua_pushthread = int function(lua_State*); ///
	alias da_lua_getglobal = int function(lua_State*, const(char)*); ///
	alias da_lua_gettable = int function(lua_State*, int); ///
	alias da_lua_getfield = int function(lua_State*, int, const(char)*); ///
	alias da_lua_geti = int function(lua_State*, int, lua_Integer); ///
	alias da_lua_rawget = int function(lua_State*, int); ///
	alias da_lua_rawgeti = int function(lua_State*, int, int); ///
	alias da_lua_rawgetp = int function(lua_State*, int, const(void)*); ///
	alias da_lua_createtable = void function(lua_State*, int, int); ///
	alias da_lua_newuserdata = void* function(lua_State*, size_t); ///
	alias da_lua_getmetatable = int function(lua_State*, int); ///
	alias da_lua_getuservalue = int function(lua_State*, int); ///
	alias da_lua_setglobal = void function(lua_State*, const(char)*); ///
	alias da_lua_settable = void function(lua_State*, int); ///
	alias da_lua_setfield = void function(lua_State*, int, const(char)*); ///
	alias da_lua_rawset = void function(lua_State*, int); ///
	alias da_lua_rawseti = void function(lua_State*, int, lua_Integer); ///
	alias da_lua_rawsetp = void function(lua_State*, int, const(void)*); ///
	alias da_lua_setmetatable = int function(lua_State*, int); ///
	alias da_lua_setuservalue = void function(lua_State*, int); ///
	alias da_lua_callk = void function(lua_State*, int, int, lua_KContext, lua_KFunction); ///
	alias da_lua_pcallk = int function(lua_State*, int, int, int, lua_KContext, lua_KFunction); ///
	alias da_lua_load = int function(lua_State*, lua_Reader, void*, const(char)*, const(char)*); ///
	alias da_lua_dump = int function(lua_State*, lua_Writer, void*, int); ///
	alias da_lua_yieldk = int function(lua_State*, int, lua_KContext, lua_KFunction); ///
	alias da_lua_resume = int function(lua_State*, lua_State*, int); ///
	alias da_lua_status = int function(lua_State*); ///
	alias da_lua_isyieldable = int function(lua_State*); ///
	alias da_lua_gc = int function(lua_State*, int, int); ///
	alias da_lua_error = int function(lua_State*); ///
	alias da_lua_next = int function(lua_State*, int); ///
	alias da_lua_concat = void function(lua_State*, int); ///
	alias da_lua_len = void function(lua_State*, int); ///
	alias da_lua_stringtonumber = size_t function(lua_State*, const(char)*); ///
	alias da_lua_getallocf = lua_Alloc function(lua_State*, void**); ///
	alias da_lua_setallocf = void function(lua_State*, lua_Alloc, void*); ///
	alias da_lua_getstack = int function(lua_State*, int, lua_Debug*); ///
	alias da_lua_getinfo = int function(lua_State*, const(char)*, lua_Debug*); ///
	alias da_lua_getlocal = const(char)* function(lua_State*, const(lua_Debug)*, int); ///
	alias da_lua_setlocal = const(char)* function(lua_State*, const(lua_Debug)*, int); ///
	alias da_lua_getupvalue = const(char)* function(lua_State*, int, int); ///
	alias da_lua_setupvalue = const(char)* function(lua_State*, int, int); ///
	alias da_lua_upvalueid = void* function(lua_State*, int, int); ///
	alias da_lua_upvaluejoin = void function(lua_State*, int, int, int, int); ///
	alias da_lua_sethook = void function(lua_State*, lua_Hook, int, int); ///
	alias da_lua_gethook = lua_Hook function(lua_State*); ///
	alias da_lua_gethookmask = int function(lua_State*); ///
	alias da_lua_gethookcount = int function(lua_State*); ///

	alias da_luaL_checkversion_ = void function(lua_State*, lua_Number, size_t); ///
	alias da_luaL_getmetafield = int function(lua_State*, int, const(char)*); ///
	alias da_luaL_callmeta = int function(lua_State*, int, const(char)*); ///
	alias da_luaL_tolstring = const(char)* function(lua_State*, int, size_t*); ///
	alias da_luaL_argerror = int function(lua_State*, int, const(char)*); ///
	alias da_luaL_checklstring = const(char)* function(lua_State*, int, size_t*); ///
	alias da_luaL_optlstring = const(char)* function(lua_State*, int, const(char)*, size_t*); ///
	alias da_luaL_checknumber = lua_Number function(lua_State*, int); ///
	alias da_luaL_optnumber = lua_Number function(lua_State*, int, lua_Number); ///
	alias da_luaL_checkinteger = lua_Integer function(lua_State*, int); ///
	alias da_luaL_optinteger = lua_Integer function(lua_State*, int, lua_Integer); ///
	alias da_luaL_checkstack = void function(lua_State*, int, const(char)*); ///
	alias da_luaL_checktype = void function(lua_State*, int, int); ///
	alias da_luaL_checkany = void function(lua_State*, int); ///
	alias da_luaL_newmetatable = int function(lua_State*, const(char)*); ///
	alias da_luaL_setmetatable = void function(lua_State*, const(char)*); ///
	alias da_luaL_testudata = void* function(lua_State*, int, const(char)*); ///
	alias da_luaL_checkudata = void* function(lua_State*, int, const(char)*); ///
	alias da_luaL_where = void function(lua_State*, int); ///
	alias da_luaL_error = int function(lua_State*, const(char)*, ...); ///
	alias da_luaL_checkoption = int function(lua_State*, int, const(char)*); ///
	alias da_luaL_fileresult = int function(lua_State*, int, const(char)*); ///
	alias da_luaL_execresult = int function(lua_State*, int); ///
	alias da_luaL_ref = int function(lua_State*, int); ///
	alias da_luaL_unref = void function(lua_State*, int, int); ///
	alias da_luaL_loadfilex = int function(lua_State*, const(char)*, const(char)*); ///
	alias da_luaL_loadbufferx = int function(lua_State*, const(char)*, size_t, const(char)*, const(char)*); ///
	alias da_luaL_loadstring = int function(lua_State*, const(char)*); ///
	alias da_luaL_newstate = lua_State* function(); ///
	alias da_luaL_len = lua_Integer function(lua_State*, int); ///
	alias da_luaL_gsub = const(char)* function(lua_State*, const(char)*, const(char)*, const(char)*); ///
	alias da_luaL_setfuncs = void function(lua_State*, const luaL_Reg*, int); ///
	alias da_luaL_getsubtable = int function(lua_State*, int, const(char)*); ///
	alias da_luaL_traceback = void function(lua_State*, lua_State*, const(char)*, int); ///
	alias da_luaL_requiref = void function(lua_State*, const(char)*, lua_CFunction, int); ///
	alias da_luaL_buffinit = void function(lua_State*, luaL_Buffer*); ///
	alias da_luaL_prepbuffsize = char* function(luaL_Buffer*, size_t); ///
	alias da_luaL_addlstring = void function(luaL_Buffer*, const(char)*, size_t); ///
	alias da_luaL_addstring = void function(luaL_Buffer*, const(char)*); ///
	alias da_luaL_addvalue = void function(luaL_Buffer*); ///
	alias da_luaL_pushresult = void function(luaL_Buffer*); ///
	alias da_luaL_pushresultsize = void function(luaL_Buffer*, size_t); ///
	alias da_luaL_buffinitsize = char* function(lua_State*, luaL_Buffer*, size_t); ///
	alias da_luaL_pushmodule = void function(lua_State*, const(char)*, int); ///
	alias da_luaL_openlib = void function(lua_State*, const(char)*, const(luaL_Reg)*, int); ///

	alias da_luaopen_base = int function(lua_State*); ///
	alias da_luaopen_coroutine = int function(lua_State*); ///
	alias da_luaopen_table = int function(lua_State*); ///
	alias da_luaopen_io = int function(lua_State*); ///
	alias da_luaopen_os = int function(lua_State*); ///
	alias da_luaopen_string = int function(lua_State*); ///
	alias da_luaopen_utf8 = int function(lua_State*); ///
	alias da_luaopen_bit32 = int function(lua_State*); ///
	alias da_luaopen_math = int function(lua_State*); ///
	alias da_luaopen_debug = int function(lua_State*); ///
	alias da_luaopen_package = int function(lua_State*); ///
	alias da_luaL_openlibs = void function(lua_State*); ///
}
