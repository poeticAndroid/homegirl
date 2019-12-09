
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.lua.v52;

version(LUA_52):

public import bindbc.lua.v52.types;

version(BindBC_Static) version = BindLua_Static;
version(BindLua_Static) {
    public import bindbc.lua.v52.bindstatic;
}
else public import bindbc.lua.v52.binddynamic;

import core.stdc.config : c_long;

// compatibility function aliases
// luaconf.h
alias lua_strlen = lua_rawlen;
alias lua_objlen = lua_rawlen;

// Macros
@nogc nothrow {
    // luaconf.h
    int lua_equal(lua_State* L, int idx1, int idx2) {
        pragma(inline, true)
        return lua_compare(L, idx1, idx2, LUA_OPEQ);
    }

    int lua_lessthan(lua_State* L, int idx1, int idx2) {
        pragma(inline, true)
        return lua_compare(L, idx1, idx2, LUA_OPLT);
    }

    // lauxlib.h
    void luaL_checkversion(lua_State* L) {
        pragma(inline, true)
        luaL_checkversion_(L, LUA_VERSION_NUM);
    }

    int luaL_loadfile(lua_State* L, const(char)* filename) {
        pragma(inline, true)
        return luaL_loadfilex(L, filename, null);
    }

    void luaL_newlibtable(lua_State* L, const(luaL_Reg)[] l) {
        pragma(inline, true)
        lua_createtable(L, 0, cast(int)l.length - 1);
    }

    void luaL_newlib(lua_State* L, const(luaL_Reg)[] l) {
        pragma(inline, true)
        luaL_newlibtable(L, l);
        luaL_setfuncs(L, l.ptr, 0);
    }

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

    int luaL_loadbuffer(lua_State *L, const(char)* buff, size_t sz, const(char)* name) {
        pragma(inline, true)
        return luaL_loadbufferx(L, buff, sz, name, null);
    }

    void luaL_addchar(luaL_Buffer* B, char c) {
        pragma(inline, true)
        if(B.n < B.size || luaL_prepbuffsize(B, 1)) {
            B.b[B.n++] = c;
        }
    }

    void luaL_addsize(luaL_Buffer* B, size_t s) {
        pragma(inline, true)
        B.n += s;
    }

    char* luaL_prepbuffer(luaL_Buffer* B) {
        pragma(inline, true)
        return luaL_prepbuffsize(B, LUAL_BUFFERSIZE);
    }

    // lua.h
    int lua_upvalueindex(int i) {
        pragma(inline, true)
        return LUA_REGISTRYINDEX - i;
    }

    void lua_call(lua_State* L, int n, int r) {
        pragma(inline, true)
        lua_callk(L, n, r, 0, null);
    }

    int lua_pcall(lua_State* L, int n, int r, int f) {
        pragma(inline, true)
        return lua_pcallk(L, n, r, f, 0, null);
    }

    int lua_yield(lua_State* L, int n) {
        pragma(inline, true)
        return lua_yieldk(L, n, 0, null);
    }

    lua_Number lua_tonumber(lua_State* L, int i) {
        pragma(inline, true)
        return lua_tonumberx(L, i, null);
    }

    lua_Integer lua_tointeger(lua_State* L, int i) {
        pragma(inline, true)
        return lua_tointegerx(L, i, null);
    }

    lua_Unsigned lua_tounsigned(lua_State* L, int i) {
        pragma(inline, true)
        return lua_tounsignedx(L, i, null);
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

    void lua_pushglobaltable(lua_State* L) {
        pragma(inline, true)
        lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
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