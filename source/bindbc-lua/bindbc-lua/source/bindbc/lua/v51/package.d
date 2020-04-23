
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.lua.v51;

version(LUA_51):

public import bindbc.lua.v51.types;

version(BindBC_Static) version = BindLua_Static;
version(BindLua_Static) {
    public import bindbc.lua.v51.bindstatic;
}
else public import bindbc.lua.v51.binddynamic;

import core.stdc.config : c_long;

// compatibility function aliases
// lua.h
alias lua_strlen = lua_objlen;
alias lua_open = lua_newstate;

// Macros
@nogc nothrow {
    // lauxlib.h
    void luaL_argcheck(lua_State* L, bool cond, int arg, const(char)* extramsg) {
        pragma(inline, true)
        if(!cond) luaL_argerror(L, arg, extramsg);
    }

    const(char)* luaL_checkstring(lua_State* L, int arg) {
        pragma(inline, true)
        return luaL_checklstring(L, arg, null);
    }

    const(char)* luaL_optstring(lua_State* L, int arg, const(char)* d) {
        pragma(inline, true)
        return luaL_optlstring(L, arg, d, null);
    }

    int luaL_checkint(lua_State* L, int arg) {
        pragma(inline, true)
        return cast(int)luaL_checkinteger(L, arg);
    }

    int luaL_optint(lua_State* L, int arg, int d) {
        pragma(inline, true)
        return cast(int)luaL_optinteger(L, arg, d);
    }

    c_long luaL_checklong(lua_State* L, int arg) {
        pragma(inline, true)
        return cast(c_long)luaL_checkinteger(L, arg);
    }

    c_long luaL_optlong(lua_State* L, int arg, int d) {
        pragma(inline, true)
        return cast(c_long)luaL_optinteger(L, arg, d);
    }

    const(char)* luaL_typename(lua_State* L, int i) {
        pragma(inline, true)
        return lua_typename(L, lua_type(L, i));
    }

    bool luaL_dofile(lua_State* L, const(char)* filename) {
        pragma(inline, true)
        return luaL_loadfile(L, filename) != 0 || lua_pcall(L, 0, LUA_MULTRET, 0) != 0;
    }

    bool luaL_dostring(lua_State* L, const(char)* str) {
        pragma(inline, true)
        return luaL_loadstring(L, str) != 0 || lua_pcall(L, 0, LUA_MULTRET, 0) != 0;
    }

    void luaL_getmetatable(lua_State* L, const(char)* tname) {
        pragma(inline, true)
        lua_getfield(L, LUA_REGISTRYINDEX, tname);
    }

    // TODO: figure out what luaL_opt is supposed to do

    void luaL_addchar(luaL_Buffer* B, char c) {
        pragma(inline, true)
        if(B.p < (B.buffer.ptr + LUAL_BUFFERSIZE) || luaL_prepbuffer(B)) {
            *B.p++ = c;
        }
    }

    void luaL_addsize(luaL_Buffer* B, size_t n) {
        pragma(inline, true)
        B.p += n;
    }

    // lua.h
    int lua_upvalueindex(int i) {
        pragma(inline, true)
        return LUA_GLOBALSINDEX - i;
    }

    void lua_pop(lua_State* L, int n) {
        pragma(inline, true)
        lua_settop(L, -n - 1);
    }

    void lua_newtable(lua_State* L) {
        pragma(inline, true)
        lua_createtable(L, 0, 0);
    }

    void lua_register(lua_State* L, const(char)* n, lua_CFunction f) {
        pragma(inline, true)
        lua_pushcfunction(L, f);
        lua_setglobal(L, n);
    }

    void lua_pushcfunction(lua_State* L, lua_CFunction f) {
        pragma(inline, true)
        lua_pushcclosure(L, f, 0);
    }

    bool lua_isfunction(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TFUNCTION;
    }

    bool lua_istable(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TTABLE;
    }

    bool lua_islightuserdata(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TLIGHTUSERDATA;
    }

    bool lua_isnil(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TNIL;
    }

    bool lua_isboolean(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TBOOLEAN;
    }

    bool lua_isthread(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TTHREAD;
    }

    bool lua_isnone(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) == LUA_TNONE;
    }

    bool lua_isnoneornil(lua_State* L, int n) {
        pragma(inline, true)
        return lua_type(L, n) <= 0;
    }

    void lua_pushliteral(lua_State* L, const(char)[] s) {
        pragma(inline, true)
        lua_pushlstring(L, s.ptr, s.length);
    }

    void lua_setglobal(lua_State* L, const(char)* s) {
        pragma(inline, true)
        lua_setfield(L, LUA_GLOBALSINDEX, s);
    }

    void lua_getglobal(lua_State* L, const(char)* s) {
        pragma(inline, true)
        lua_getfield(L, LUA_GLOBALSINDEX, s);
    }

    const(char)* lua_tostring(lua_State* L, int i) {
        pragma(inline, true)
        return lua_tolstring(L, i, null);
    }

    void lua_getregistry(lua_State* L) {
        pragma(inline, true)
        lua_pushvalue(L, LUA_REGISTRYINDEX);
    }

    int lua_getgccount(lua_State* L) {
        pragma(inline, true)
        return lua_gc(L, LUA_GCCOUNT, 0);
    }
}