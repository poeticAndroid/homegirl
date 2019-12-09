
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.lua.v51.types;

version(LUA_51):

import core.stdc.stdio : BUFSIZ;

// luaconf.h
enum LUA_IDSIZE = 60;
alias LUAI_UINT32 = uint;
alias LUAI_INT32 = int;
enum LUAI_MAXINT32 = int.max;
alias LUAI_UMEM = size_t;
alias LUAI_MEM = ptrdiff_t;
alias LUA_NUMBER = double;
alias LUA_INTEGER = ptrdiff_t;

enum LUAL_BUFFERSIZE = BUFSIZ;

enum LUAI_MAXSTACK = 1000000;

// lauxlib.h
enum LUA_ERRFILE = LUA_ERRERR+1;

struct luaL_Reg {
    const(char)* name;
    lua_CFunction func;
}

enum LUA_NOREF = -2;
enum LUA_REFNIL = -1;

struct luaL_Buffer {
    char* p;
    int lvl;
    lua_State* L;
    char[LUAL_BUFFERSIZE] buffer;
}

// lua.h
// The 5.1 header does not define LUA_VERSION_MAJOR/MINOR/NUM/RELEASE, but we will
// for consistency with the other versions.
enum LUA_VERSION_MAJOR = "5";
enum LUA_VERSION_MINOR = "1";
enum LUA_VERSION_NUM = 501;
enum LUA_VERSION_RELEASE = 5;

enum LUA_VERSION = "Lua " ~ LUA_VERSION_MAJOR ~ "." ~ LUA_VERSION_MINOR;
enum LUA_RELEASE = LUA_VERSION ~ "." ~ LUA_VERSION_RELEASE;

enum LUA_SIGNATURE = "\033Lua";
enum LUA_MULTRET = -1;

enum LUA_REGISTRYINDEX = -10_000;
enum LUA_ENVIRONINDEX = -10_001;
enum LUA_GLOBALSINDEX = -10_002;

enum LUA_YIELD = 1;
enum LUA_ERRRUN = 2;
enum LUA_ERRSYNTAX = 3;
enum LUA_ERRMEM = 4;
enum LUA_ERRERR = 5;

struct lua_State;

nothrow {
    alias lua_CFunction = int function(lua_State*);
    alias lua_Reader = const(char)* function(lua_State*,void*,size_t);
    alias lua_Writer = int function(lua_State*,const(void)*,size_t,void*);
    alias lua_Alloc = void* function(void*,void*,size_t,size_t);
}

enum LUA_TNONE = -1;
enum LUA_TNIL = 0;
enum LUA_TBOOLEAN = 1;
enum LUA_TLIGHTUSERDATA = 2;
enum LUA_TNUMBER = 3;
enum LUA_TSTRING = 4;
enum LUA_TTABLE = 5;
enum LUA_TFUNCTION = 6;
enum LUA_TUSERDATA = 7;
enum LUA_TTHREAD = 8;

enum LUA_MINSTACK = 20;

alias lua_Number = LUA_NUMBER;
alias lua_Integer = LUA_INTEGER;

enum LUA_GCSTOP = 0;
enum LUA_GCRESTART = 1;
enum LUA_GCCOLLECT = 2;
enum LUA_GCCOUNT = 3;
enum LUA_GCCOUNTB = 4;
enum LUA_GCSTEP = 5;
enum LUA_GCSETPAUSE = 6;
enum LUA_GCSETSTEPMUL = 7;

enum LUA_HOOKCALL = 0;
enum LUA_HOOKRET = 1;
enum LUA_HOOKLINE = 2;
enum LUA_HOOKCOUNT = 3;
enum LUA_HOOKTAILRET = 4;

enum LUA_MASKCALL = 1 << LUA_HOOKCALL;
enum LUA_MASKRET = 1 << LUA_HOOKRET;
enum LUA_MASKLINE = 1 << LUA_HOOKLINE;
enum LUA_MASKCOUNT = 1 << LUA_HOOKCOUNT;

struct lua_Debug {
    int event;
    const(char)* name;
    const(char)* namewhat;
    const(char)* what;
    const(char)* source;
    int currentline;
    int nups;
    int linedefined;
    int lastlinedefined;
    char[LUA_IDSIZE] short_src;
    private int i_ci;
}

alias lua_Hook = void function(lua_State*,lua_Debug*) nothrow;

// lualib.h
enum LUA_FILEHANDLE = "FILE*";
enum LUA_COLIBNAME = "coroutine";
enum LUA_TABLIBNAME = "table";
enum LUA_IOLIBNAME = "io";
enum LUA_OSLIBNAME = "os";
enum LUA_STRLIBNAME = "string";
enum LUA_MATHLIBNAME = "math";
enum LUA_DBLIBNAME = "debug";
enum LUA_LOADLIBNAME = "package";