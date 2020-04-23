
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.lua.v51.binddynamic;

version(BindBC_Static) version = BindLua_Static;
version(BindLua_Static) {}
else version = BindLua_Dynamic;

version(LUA_51) {
    version(BindLua_Dynamic) version = LUA_51_DYNAMIC;
}

version(LUA_51_DYNAMIC):

import core.stdc.stdarg : va_list;
import bindbc.loader;
import bindbc.lua.config;
import bindbc.lua.v51.types;

extern(C) @nogc nothrow {
    // lauxlib.h
    alias pluaI_openlib = void function(lua_State*,const(char)*,const(luaL_Reg)*,int);
    alias pluaL_register = void function(lua_State*,const(char)*,const(luaL_Reg)*);
    alias pluaL_getmetafield = int function(lua_State*,int,const(char)*);
    alias pluaL_callmeta = int function(lua_State*, int,const(char)*);
    alias pluaL_typerror = int function(lua_State*,int,const(char)*);
    alias pluaL_argerror = int function(lua_State*,int,const(char)*);
    alias pluaL_checklstring = const(char)* function(lua_State*,int,size_t*);
    alias pluaL_optlstring = const(char)* function(lua_State*,int,const(char)*,size_t*);
    alias pluaL_checknumber = lua_Number function(lua_State*,int);
    alias pluaL_optnumber = lua_Number function(lua_State*,int,lua_Number);
    alias pluaL_checkinteger = lua_Integer function(lua_State*,int);
    alias pluaL_optinteger = lua_Integer function(lua_State*,int,lua_Integer);
    alias pluaL_checkstack = void function(lua_State*,int,const(char)*);
    alias pluaL_checktype = void function(lua_State*,int,int);
    alias pluaL_checkany = void function(lua_State*,int);
    alias pluaL_newmetatable = int function(lua_State*,const(char)*);
    alias pluaL_checkudata = void* function(lua_State*,int,const(char)*);
    alias pluaL_where = void function(lua_State*,int);
    alias pluaL_error = int function(lua_State*,const(char)*,...);
    alias pluaL_checkoption = int function(lua_State*,int,const(char)*);
    alias pluaL_ref = int function(lua_State*,int);
    alias pluaL_unref = void function(lua_State*,int,int);
    alias pluaL_loadfile = int function(lua_State*,const(char)*);
    alias pluaL_loadbuffer = int function(lua_State*,const(char)*,size_t,const(char)*);
    alias pluaL_loadstring = int function(lua_State*,const(char)*);
    alias pluaL_newstate = lua_State* function();
    alias pluaL_gsub = const(char)* function(lua_State*,const(char)*,const(char)*,const(char)*);
    alias pluaL_findtable = const(char)* function(lua_State*,int,const(char)*,int);
    alias pluaL_buffinit = void function(lua_State*,luaL_Buffer*);
    alias pluaL_prepbuffer = char* function(luaL_Buffer*);
    alias pluaL_addlstring = void function(luaL_Buffer*,const(char)*,size_t);
    alias pluaL_addstring = void function(luaL_Buffer*, const(char)*);
    alias pluaL_addvalue = void function(luaL_Buffer*);
    alias pluaL_pushresult = void function(luaL_Buffer*);

    // lua.h
    alias plua_newstate = lua_State* function(lua_Alloc,void*);
    alias plua_close = void function(lua_State*);
    alias plua_newthread = lua_State* function(lua_State*);
    alias plua_atpanic = lua_CFunction function(lua_State*,lua_CFunction);
    alias plua_gettop = int function(lua_State*);
    alias plua_settop = void function(lua_State*,int);
    alias plua_pushvalue = void function(lua_State*,int);
    alias plua_remove = void function(lua_State*,int);
    alias plua_insert = void function(lua_State*,int);
    alias plua_replace = void function(lua_State*,int);
    alias plua_checkstack = int function(lua_State*,int);
    alias plua_xmove = void function(lua_State*,lua_State*,int);
    alias plua_isnumber = int function(lua_State*,int);
    alias plua_isstring = int function(lua_State*,int);
    alias plua_iscfunction = int function(lua_State*,int);
    alias plua_isuserdata = int function(lua_State*,int);
    alias plua_type = int function(lua_State*,int);
    alias plua_typename = const(char)* function(lua_State*,int);
    alias plua_equal = int function(lua_State*,int,int);
    alias plua_rawequal = int function(lua_State*,int,int);
    alias plua_lessthan = int function(lua_State*,int,int);
    alias plua_tonumber = lua_Number function(lua_State*,int);
    alias plua_tointeger = lua_Integer function(lua_State*,int);
    alias plua_toboolean = int function(lua_State*,int);
    alias plua_tolstring = const(char)* function(lua_State*,int,size_t*);
    alias plua_objlen = size_t function(lua_State*,int);
    alias plua_tocfunction = lua_CFunction function(lua_State*,int);
    alias plua_touserdata = void* function(lua_State*,int);
    alias plua_tothread = lua_State* function(lua_State*,int);
    alias plua_topointer = const(void)* function(lua_State*,int);
    alias plua_pushnil = void function(lua_State*);
    alias plua_pushnumber = void function(lua_State*,lua_Number);
    alias plua_pushinteger = void function(lua_State*,lua_Integer);
    alias plua_pushlstring = void function(lua_State*,const(char)*,size_t);
    alias plua_pushstring = void function(lua_State*,const(char)*);
    alias plua_pushvfstring = const(char)* function(lua_State*,const(char)*,va_list);
    alias plua_pushfstring = const(char)* function(lua_State*,const(char)*,...);
    alias plua_pushcclosure = void function(lua_State*,lua_CFunction,int);
    alias plua_pushboolean = void function(lua_State*,int);
    alias plua_pushlightuserdata = void function(lua_State*,void*);
    alias plua_pushthread = int function(lua_State*);
    alias plua_gettable = void function(lua_State*,int);
    alias plua_getfield = void function(lua_State*,int,const(char)*);
    alias plua_rawget = void function(lua_State*,int);
    alias plua_rawgeti = void function(lua_State*,int,int);
    alias plua_createtable = void function(lua_State*,int,int);
    alias plua_newuserdata = void* function(lua_State*,size_t);
    alias plua_getmetatable = int function(lua_State*,int);
    alias plua_getfenv = void function(lua_State*,int);
    alias plua_settable = void function(lua_State*,int);
    alias plua_setfield = void function(lua_State*,int,const(char)*);
    alias plua_rawset = void function(lua_State*,int);
    alias plua_rawseti = void function(lua_State*,int,int);
    alias plua_setmetatable = int function(lua_State*,int);
    alias plua_setfenv = int function(lua_State*,int);
    alias plua_call = void function(lua_State*,int,int);
    alias plua_pcall = int function(lua_State*,int,int,int);
    alias plua_cpcall = int function(lua_State*,lua_CFunction,void*);
    alias plua_load = int function(lua_State*,lua_Reader,void*,const(char)*);
    alias plua_dump = int function(lua_State*,lua_Writer,void*);
    alias plua_yield = int function(lua_State*,int);
    alias plua_resume = int function(lua_State*,int);
    alias plua_status = int function(lua_State*);
    alias plua_gc = int function(lua_State*,int,int);
    alias plua_error = int function(lua_State*);
    alias plua_next = int function(lua_State*,int);
    alias plua_concat = void function(lua_State*,int);
    alias plua_getallocf = lua_Alloc function(lua_State*,void**);
    alias plua_setallocf = void function(lua_State*,lua_Alloc,void*);
    alias plua_setlevel = void function(lua_State*, lua_State*);
    alias plua_getstack = int function(lua_State*,int,lua_Debug*);
    alias plua_getinfo = int function(lua_State*,const(char)*,lua_Debug*);
    alias plua_getlocal = const(char)* function(lua_State*,const(lua_Debug)*,int);
    alias plua_setlocal = const(char)* function(lua_State*,const(lua_Debug)*,int);
    alias plua_getupvalue = const(char)* function(lua_State*,int,int);
    alias plua_setupvalue = const(char)* function(lua_State*,int,int);
    alias plua_sethook = int function(lua_State*,lua_Hook,int,int);
    alias plua_gethook = lua_Hook function(lua_State*);
    alias plua_gethookmask = int function(lua_State*);
    alias plua_gethookcount = int function(lua_State*);

    // lualib.h
    alias pluaopen_base = int function(lua_State*);
    alias pluaopen_table = int function(lua_State*);
    alias pluaopen_io = int function(lua_State*);
    alias pluaopen_os = int function(lua_State*);
    alias pluaopen_string = int function(lua_State*);
    alias pluaopen_math = int function(lua_State*);
    alias pluaopen_debug = int function(lua_State*);
    alias pluaopen_package = int function(lua_State*);
    alias pluaL_openlibs = void function(lua_State*);
}

__gshared {
    // lauxlib.h
    pluaI_openlib luaI_openlib;
    pluaL_register luaL_register;
    pluaL_getmetafield luaL_getmetafield;
    pluaL_callmeta luaL_callmeta;
    pluaL_typerror luaL_typerror;
    pluaL_argerror luaL_argerror;
    pluaL_checklstring luaL_checklstring;
    pluaL_optlstring luaL_optlstring;
    pluaL_checknumber luaL_checknumber;
    pluaL_optnumber luaL_optnumber;
    pluaL_checkinteger luaL_checkinteger;
    pluaL_optinteger luaL_optinteger;
    pluaL_checkstack luaL_checkstack;
    pluaL_checktype luaL_checktype;
    pluaL_checkany luaL_checkany;
    pluaL_newmetatable luaL_newmetatable;
    pluaL_checkudata luaL_checkudata;
    pluaL_where luaL_where;
    pluaL_error luaL_error;
    pluaL_checkoption luaL_checkoption;
    pluaL_ref luaL_ref;
    pluaL_unref luaL_unref;
    pluaL_loadfile luaL_loadfile;
    pluaL_loadbuffer luaL_loadbuffer;
    pluaL_loadstring luaL_loadstring;
    pluaL_newstate luaL_newstate;
    pluaL_gsub luaL_gsub;
    pluaL_findtable luaL_findtable;
    pluaL_buffinit luaL_buffinit;
    pluaL_prepbuffer luaL_prepbuffer;
    pluaL_addlstring luaL_addlstring;
    pluaL_addstring luaL_addstring;
    pluaL_addvalue luaL_addvalue;
    pluaL_pushresult luaL_pushresult;

    // lua.h
    plua_newstate lua_newstate;
    plua_close lua_close;
    plua_newthread lua_newthread;
    plua_atpanic lua_atpanic;
    plua_gettop lua_gettop;
    plua_settop lua_settop;
    plua_pushvalue lua_pushvalue;
    plua_remove lua_remove;
    plua_insert lua_insert;
    plua_replace lua_replace;
    plua_checkstack lua_checkstack;
    plua_xmove lua_xmove;
    plua_isnumber lua_isnumber;
    plua_isstring lua_isstring;
    plua_iscfunction lua_iscfunction;
    plua_isuserdata lua_isuserdata;
    plua_type lua_type;
    plua_typename lua_typename;
    plua_equal lua_equal;
    plua_rawequal lua_rawequal;
    plua_lessthan lua_lessthan;
    plua_tonumber lua_tonumber;
    plua_tointeger lua_tointeger;
    plua_toboolean lua_toboolean;
    plua_tolstring lua_tolstring;
    plua_objlen lua_objlen;
    plua_tocfunction lua_tocfunction;
    plua_touserdata lua_touserdata;
    plua_tothread lua_tothread;
    plua_topointer lua_topointer;
    plua_pushnil lua_pushnil;
    plua_pushnumber lua_pushnumber;
    plua_pushinteger lua_pushinteger;
    plua_pushlstring lua_pushlstring;
    plua_pushstring lua_pushstring;
    plua_pushvfstring lua_pushvfstring;
    plua_pushfstring lua_pushfstring;
    plua_pushcclosure lua_pushcclosure;
    plua_pushboolean lua_pushboolean;
    plua_pushlightuserdata lua_pushlightuserdata;
    plua_pushthread lua_pushthread;
    plua_gettable lua_gettable;
    plua_getfield lua_getfield;
    plua_rawget lua_rawget;
    plua_rawgeti lua_rawgeti;
    plua_createtable lua_createtable;
    plua_newuserdata lua_newuserdata;
    plua_getmetatable lua_getmetatable;
    plua_getfenv lua_getfenv;
    plua_settable lua_settable;
    plua_setfield lua_setfield;
    plua_rawset lua_rawset;
    plua_rawseti lua_rawseti;
    plua_setmetatable lua_setmetatable;
    plua_setfenv lua_setfenv;
    plua_call lua_call;
    plua_pcall lua_pcall;
    plua_cpcall lua_cpcall;
    plua_load lua_load;
    plua_dump lua_dump;
    plua_yield lua_yield;
    plua_resume lua_resume;
    plua_status lua_status;
    plua_gc lua_gc;
    plua_error lua_error;
    plua_next lua_next;
    plua_concat lua_concat;
    plua_getallocf lua_getallocf;
    plua_setallocf lua_setallocf;
    plua_setlevel lua_setlevel;
    plua_getstack lua_getstack;
    plua_getinfo lua_getinfo;
    plua_getlocal lua_getlocal;
    plua_setlocal lua_setlocal;
    plua_getupvalue lua_getupvalue;
    plua_setupvalue lua_setupvalue;
    plua_sethook lua_sethook;
    plua_gethook lua_gethook;
    plua_gethookmask lua_gethookmask;
    plua_gethookcount lua_gethookcount;

    // lualib.h
    pluaopen_base luaopen_base;
    pluaopen_table luaopen_table;
    pluaopen_io luaopen_io;
    pluaopen_os luaopen_os;
    pluaopen_string luaopen_string;
    pluaopen_math luaopen_math;
    pluaopen_debug luaopen_debug;
    pluaopen_package luaopen_package;
    pluaL_openlibs luaL_openlibs;
}

private {
    SharedLib lib;
    LuaSupport loadedVersion;
}

@nogc nothrow:

void unloadLua()
{
    if(lib != invalidHandle) {
        lib.unload;
    }
}

LuaSupport loadedLuaVersion() @safe { return loadedVersion; }
bool isLuaLoaded() @safe { return lib != invalidHandle; }

LuaSupport loadLua()
{
    version(Windows) {
        const(char)[][3] libNames = ["lua5.1.dll", "lua51.dll", "lua5.1.5.dll"];
    }
    else version(OSX) {
        const(char)[][1] libNames = "liblua.5.1.dylib";
    }
    else version(Posix) {
        const(char)[][1] libNames = "liblua.so.5.1";
    }
    else static assert(0, "bindbc-lua support for Lua 5.1 is not implemented on this platform.");

    LuaSupport ret;
    foreach(name; libNames) {
        ret = loadLua(name.ptr);
        if(ret != LuaSupport.noLibrary) break;
    }
    return ret;
}

LuaSupport loadLua(const(char)* libName)
{
    lib = load(libName);
    if(lib == invalidHandle) {
        return LuaSupport.noLibrary;
    }

    auto errCount = errorCount();
    loadedVersion = LuaSupport.badLibrary;

    // lauxlib.h
    lib.bindSymbol(cast(void**)&luaI_openlib, "luaI_openlib");
    lib.bindSymbol(cast(void**)&luaL_register, "luaL_register");
    lib.bindSymbol(cast(void**)&luaL_getmetafield,"luaL_getmetafield");
    lib.bindSymbol(cast(void**)&luaL_callmeta, "luaL_callmeta");
    lib.bindSymbol(cast(void**)&luaL_typerror, "luaL_typerror");
    lib.bindSymbol(cast(void**)&luaL_checklstring, "luaL_checklstring");
    lib.bindSymbol(cast(void**)&luaL_argerror, "luaL_argerror");
    lib.bindSymbol(cast(void**)&luaL_optlstring, "luaL_optlstring");
    lib.bindSymbol(cast(void**)&luaL_checknumber, "luaL_checknumber");
    lib.bindSymbol(cast(void**)&luaL_optnumber, "luaL_optnumber");
    lib.bindSymbol(cast(void**)&luaL_checkinteger, "luaL_checkinteger");
    lib.bindSymbol(cast(void**)&luaL_optinteger, "luaL_optinteger");
    lib.bindSymbol(cast(void**)&luaL_checkstack, "luaL_checkstack");
    lib.bindSymbol(cast(void**)&luaL_checktype, "luaL_checktype");
    lib.bindSymbol(cast(void**)&luaL_checkany, "luaL_checkany");
    lib.bindSymbol(cast(void**)&luaL_newmetatable, "luaL_newmetatable");
    lib.bindSymbol(cast(void**)&luaL_checkudata, "luaL_checkudata");
    lib.bindSymbol(cast(void**)&luaL_where, "luaL_where");
    lib.bindSymbol(cast(void**)&luaL_error, "luaL_error");
    lib.bindSymbol(cast(void**)&luaL_checkoption, "luaL_checkoption");
    lib.bindSymbol(cast(void**)&luaL_ref, "luaL_ref");
    lib.bindSymbol(cast(void**)&luaL_unref, "luaL_unref");
    lib.bindSymbol(cast(void**)&luaL_loadfile, "luaL_loadfile");
    lib.bindSymbol(cast(void**)&luaL_loadbuffer, "luaL_loadbuffer");
    lib.bindSymbol(cast(void**)&luaL_loadstring, "luaL_loadstring");
    lib.bindSymbol(cast(void**)&luaL_newstate, "luaL_newstate");
    lib.bindSymbol(cast(void**)&luaL_gsub, "luaL_gsub");
    lib.bindSymbol(cast(void**)&luaL_findtable, "luaL_findtable");

    lib.bindSymbol(cast(void**)&luaL_buffinit, "luaL_buffinit");
    lib.bindSymbol(cast(void**)&luaL_prepbuffer, "luaL_prepbuffer");
    lib.bindSymbol(cast(void**)&luaL_addlstring, "luaL_addlstring");
    lib.bindSymbol(cast(void**)&luaL_addstring, "luaL_addstring");
    lib.bindSymbol(cast(void**)&luaL_addvalue, "luaL_addvalue");
    lib.bindSymbol(cast(void**)&luaL_pushresult, "luaL_pushresult");

    // lua.h
    lib.bindSymbol(cast(void**)&lua_newstate, "lua_newstate");
    lib.bindSymbol(cast(void**)&lua_close, "lua_close");
    lib.bindSymbol(cast(void**)&lua_newthread, "lua_newthread");
    lib.bindSymbol(cast(void**)&lua_atpanic, "lua_atpanic");
    lib.bindSymbol(cast(void**)&lua_gettop, "lua_gettop");
    lib.bindSymbol(cast(void**)&lua_settop, "lua_settop");
    lib.bindSymbol(cast(void**)&lua_pushvalue, "lua_pushvalue");
    lib.bindSymbol(cast(void**)&lua_remove, "lua_remove");
    lib.bindSymbol(cast(void**)&lua_insert, "lua_insert");
    lib.bindSymbol(cast(void**)&lua_replace, "lua_replace");
    lib.bindSymbol(cast(void**)&lua_checkstack, "lua_checkstack");
    lib.bindSymbol(cast(void**)&lua_xmove, "lua_xmove");
    lib.bindSymbol(cast(void**)&lua_isnumber, "lua_isnumber");
    lib.bindSymbol(cast(void**)&lua_isstring, "lua_isstring");
    lib.bindSymbol(cast(void**)&lua_iscfunction, "lua_iscfunction");
    lib.bindSymbol(cast(void**)&lua_isuserdata, "lua_isuserdata");
    lib.bindSymbol(cast(void**)&lua_type, "lua_type");
    lib.bindSymbol(cast(void**)&lua_typename, "lua_typename");
    lib.bindSymbol(cast(void**)&lua_equal, "lua_equal");
    lib.bindSymbol(cast(void**)&lua_rawequal, "lua_rawequal");
    lib.bindSymbol(cast(void**)&lua_lessthan, "lua_lessthan");
    lib.bindSymbol(cast(void**)&lua_tonumber, "lua_tonumber");
    lib.bindSymbol(cast(void**)&lua_tointeger, "lua_tointeger");
    lib.bindSymbol(cast(void**)&lua_toboolean, "lua_toboolean");
    lib.bindSymbol(cast(void**)&lua_tolstring, "lua_tolstring");
    lib.bindSymbol(cast(void**)&lua_objlen, "lua_objlen");
    lib.bindSymbol(cast(void**)&lua_tocfunction, "lua_tocfunction");
    lib.bindSymbol(cast(void**)&lua_touserdata, "lua_touserdata");
    lib.bindSymbol(cast(void**)&lua_tothread, "lua_tothread");
    lib.bindSymbol(cast(void**)&lua_topointer, "lua_topointer");
    lib.bindSymbol(cast(void**)&lua_pushnil, "lua_pushnil");
    lib.bindSymbol(cast(void**)&lua_pushnumber, "lua_pushnumber");
    lib.bindSymbol(cast(void**)&lua_pushinteger, "lua_pushinteger");
    lib.bindSymbol(cast(void**)&lua_pushlstring, "lua_pushlstring");
    lib.bindSymbol(cast(void**)&lua_pushstring, "lua_pushstring");
    lib.bindSymbol(cast(void**)&lua_pushvfstring, "lua_pushvfstring");
    lib.bindSymbol(cast(void**)&lua_pushfstring, "lua_pushfstring");
    lib.bindSymbol(cast(void**)&lua_pushcclosure, "lua_pushcclosure");
    lib.bindSymbol(cast(void**)&lua_pushboolean, "lua_pushboolean");
    lib.bindSymbol(cast(void**)&lua_pushlightuserdata, "lua_pushlightuserdata");
    lib.bindSymbol(cast(void**)&lua_pushthread, "lua_pushthread");
    lib.bindSymbol(cast(void**)&lua_gettable, "lua_gettable");
    lib.bindSymbol(cast(void**)&lua_getfield, "lua_getfield");
    lib.bindSymbol(cast(void**)&lua_rawget, "lua_rawget");
    lib.bindSymbol(cast(void**)&lua_rawgeti, "lua_rawgeti");
    lib.bindSymbol(cast(void**)&lua_createtable, "lua_createtable");
    lib.bindSymbol(cast(void**)&lua_newuserdata, "lua_newuserdata");
    lib.bindSymbol(cast(void**)&lua_getmetatable, "lua_getmetatable");
    lib.bindSymbol(cast(void**)&lua_getfenv, "lua_getfenv");
    lib.bindSymbol(cast(void**)&lua_settable, "lua_settable");
    lib.bindSymbol(cast(void**)&lua_setfield, "lua_setfield");
    lib.bindSymbol(cast(void**)&lua_rawset, "lua_rawset");
    lib.bindSymbol(cast(void**)&lua_rawseti, "lua_rawseti");
    lib.bindSymbol(cast(void**)&lua_setmetatable, "lua_setmetatable");
    lib.bindSymbol(cast(void**)&lua_setfenv, "lua_setfenv");
    lib.bindSymbol(cast(void**)&lua_call, "lua_call");
    lib.bindSymbol(cast(void**)&lua_pcall, "lua_pcall");
    lib.bindSymbol(cast(void**)&lua_cpcall, "lua_cpcall");
    lib.bindSymbol(cast(void**)&lua_load, "lua_load");
    lib.bindSymbol(cast(void**)&lua_dump, "lua_dump");
    lib.bindSymbol(cast(void**)&lua_yield, "lua_yield");
    lib.bindSymbol(cast(void**)&lua_resume, "lua_resume");
    lib.bindSymbol(cast(void**)&lua_status, "lua_status");
    lib.bindSymbol(cast(void**)&lua_gc, "lua_gc");
    lib.bindSymbol(cast(void**)&lua_error, "lua_error");
    lib.bindSymbol(cast(void**)&lua_next, "lua_next");
    lib.bindSymbol(cast(void**)&lua_concat, "lua_concat");
    lib.bindSymbol(cast(void**)&lua_getallocf, "lua_getallocf");
    lib.bindSymbol(cast(void**)&lua_setallocf, "lua_setallocf");
    lib.bindSymbol(cast(void**)&lua_setlevel, "lua_setlevel");
    lib.bindSymbol(cast(void**)&lua_getstack, "lua_getstack");
    lib.bindSymbol(cast(void**)&lua_getinfo, "lua_getinfo");
    lib.bindSymbol(cast(void**)&lua_getlocal, "lua_getlocal");
    lib.bindSymbol(cast(void**)&lua_setlocal, "lua_setlocal");
    lib.bindSymbol(cast(void**)&lua_getupvalue, "lua_getupvalue");
    lib.bindSymbol(cast(void**)&lua_setupvalue, "lua_setupvalue");
    lib.bindSymbol(cast(void**)&lua_sethook, "lua_sethook");
    lib.bindSymbol(cast(void**)&lua_gethook, "lua_gethook");
    lib.bindSymbol(cast(void**)&lua_gethookmask, "lua_gethookmask");
    lib.bindSymbol(cast(void**)&lua_gethookcount, "lua_gethookcount");

    // lualib.h
    lib.bindSymbol(cast(void**)&luaopen_base, "luaopen_base");
    lib.bindSymbol(cast(void**)&luaopen_table, "luaopen_table");
    lib.bindSymbol(cast(void**)&luaopen_io, "luaopen_io");
    lib.bindSymbol(cast(void**)&luaopen_os, "luaopen_os");
    lib.bindSymbol(cast(void**)&luaopen_string, "luaopen_string");
    lib.bindSymbol(cast(void**)&luaopen_math, "luaopen_math");
    lib.bindSymbol(cast(void**)&luaopen_debug, "luaopen_debug");
    lib.bindSymbol(cast(void**)&luaopen_package, "luaopen_package");
    lib.bindSymbol(cast(void**)&luaL_openlibs, "luaL_openlibs");

    return LuaSupport.lua51;
}