
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.lua.v52.types;

version(LUA_52):

import core.stdc.stdio : BUFSIZ, FILE;

// luaconf.h
enum LUA_IDSIZE = 60;
alias LUA_INT32 = int;
alias LUAI_UMEM = size_t;
alias LUAI_MEM = ptrdiff_t;
alias LUA_NUMBER = double;
alias LUA_INTEGER = ptrdiff_t;
alias LUA_UNSIGNED = uint;

enum LUAL_BUFFERSIZE = BUFSIZ;

enum LUAI_MAXSTACK = 1000000;

enum LUAI_FIRSTPSEUDOIDX = (-LUAI_MAXSTACK - 1000);

// lauxlib.h
enum LUA_ERRFILE = LUA_ERRERR+1;

struct luaL_Reg {
    const(char)* name;
    lua_CFunction func;
}

enum LUA_NOREF = -2;
enum LUA_REFNIL = -1;

struct luaL_Buffer {
    char* b;
    size_t size;
    size_t n;
    lua_State* L;
    char[LUAL_BUFFERSIZE] buffer;
}

alias LUA_FILEHANDLE = FILE*;

struct luaL_Stream {
    FILE* f;
    lua_CFunction closef;
}

// lua.h
enum LUA_VERSION_MAJOR = "5";
enum LUA_VERSION_MINOR = "2";
enum LUA_VERSION_NUM = 502;
enum LUA_VERSION_RELEASE = 4;

enum LUA_VERSION = "Lua " ~ LUA_VERSION_MAJOR ~ "." ~ LUA_VERSION_MINOR;
enum LUA_RELEASE = LUA_VERSION ~ "." ~ LUA_VERSION_RELEASE;

enum LUA_SIGNATURE = "\033Lua";
enum LUA_MULTRET = -1;

enum LUA_REGISTRYINDEX = LUAI_FIRSTPSEUDOIDX;

enum LUA_OK = 0;
enum LUA_YIELD = 1;
enum LUA_ERRRUN = 2;
enum LUA_ERRSYNTAX = 3;
enum LUA_ERRMEM = 4;
enum LUA_ERRGCMM = 5;
enum LUA_ERRERR = 6;

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
enum LUA_NUMTAGS = 9;

enum LUA_MINSTACK = 20;

enum LUA_RIDX_MAINTHREAD = 1;
enum LUA_RIDX_GLOBALS = 2;
enum LUA_RIDX_LAST = LUA_RIDX_GLOBALS;

alias lua_Number = LUA_NUMBER;
alias lua_Integer = LUA_INTEGER;
alias lua_Unsigned = LUA_UNSIGNED;

enum LUA_OPADD = 0;
enum LUA_OPSUB = 1;
enum LUA_OPMUL = 2;
enum LUA_OPDIV = 3;
enum LUA_OPMOD = 4;
enum LUA_OPPOW = 5;
enum LUA_OPUNM = 6;

enum LUA_OPEQ = 0;
enum LUA_OPLT = 1;
enum LUA_OPLE = 2;

enum LUA_GCSTOP = 0;
enum LUA_GCRESTART = 1;
enum LUA_GCCOLLECT = 2;
enum LUA_GCCOUNT = 3;
enum LUA_GCCOUNTB = 4;
enum LUA_GCSTEP = 5;
enum LUA_GCSETPAUSE = 6;
enum LUA_GCSETSTEPMUL = 7;
enum LUA_GCSETMAJORINC = 8;
enum LUA_GCISRUNNING = 9;
enum LUA_GCGEN = 10;
enum LUA_GCINC = 11;

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
    int linedefined;
    int lastlinedefined;
    ubyte nups;
    ubyte nparams;
    char isvararg;
    char istailcall;
    char[LUA_IDSIZE] short_src;
    private void* i_ci;
}

alias lua_Hook = void function(lua_State*,lua_Debug*) nothrow;

// lualib.h
enum LUA_COLIBNAME = "coroutine";
enum LUA_TABLIBNAME = "table";
enum LUA_IOLIBNAME = "io";
enum LUA_OSLIBNAME = "os";
enum LUA_STRLIBNAME = "string";
enum LUA_BITLIBNAME = "bit32";
enum LUA_MATHLIBNAME = "math";
enum LUA_DBLIBNAME = "debug";
enum LUA_LOADLIBNAME = "package";