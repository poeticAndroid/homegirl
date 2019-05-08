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
Dynamic function declarations for Lua bindings

This file defines all dynamic function declarations for Lua library bindings.

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2018-2019
+/
module riverd.lua.dynfun;

import riverd.lua.types;


__gshared
{
	// stfu
	da_lua_newstate lua_newstate; ///
	da_lua_close lua_close; ///
	da_lua_newthread lua_newthread; ///
	da_lua_atpanic lua_atpanic; ///
	da_lua_version lua_version; ///
	da_lua_absindex lua_absindex; ///
	da_lua_gettop lua_gettop; ///
	da_lua_settop lua_settop; ///
	da_lua_pushvalue lua_pushvalue; ///
	da_lua_rotate lua_rotate; ///
	da_lua_copy lua_copy; ///
	da_lua_checkstack lua_checkstack; ///
	da_lua_xmove lua_xmove; ///
	da_lua_isnumber lua_isnumber; ///
	da_lua_isstring lua_isstring; ///
	da_lua_iscfunction lua_iscfunction; ///
	da_lua_isinteger lua_isinteger; ///
	da_lua_isuserdata lua_isuserdata; ///
	da_lua_type lua_type; ///
	da_lua_typename lua_typename; ///
	da_lua_tonumberx lua_tonumberx; ///
	da_lua_tointegerx lua_tointegerx; ///
	da_lua_toboolean lua_toboolean; ///
	da_lua_tolstring lua_tolstring; ///
	da_lua_rawlen lua_rawlen; ///
	da_lua_tocfunction lua_tocfunction; ///
	da_lua_touserdata lua_touserdata; ///
	da_lua_tothread lua_tothread; ///
	da_lua_topointer lua_topointer; ///
	da_lua_arith lua_arith; ///
	da_lua_rawequal lua_rawequal; ///
	da_lua_compare lua_compare; ///
	da_lua_pushnil lua_pushnil; ///
	da_lua_pushnumber lua_pushnumber; ///
	da_lua_pushinteger lua_pushinteger; ///
	da_lua_pushlstring lua_pushlstring; ///
	da_lua_pushstring lua_pushstring; ///
	da_lua_pushvfstring lua_pushvfstring; ///
	da_lua_pushfstring lua_pushfstring; ///
	da_lua_pushcclosure lua_pushcclosure; ///
	da_lua_pushboolean lua_pushboolean; ///
	da_lua_pushlightuserdata lua_pushlightuserdata; ///
	da_lua_pushthread lua_pushthread; ///
	da_lua_getglobal lua_getglobal; ///
	da_lua_gettable lua_gettable; ///
	da_lua_getfield lua_getfield; ///
	da_lua_geti lua_geti; ///
	da_lua_rawget lua_rawget; ///
	da_lua_rawgeti lua_rawgeti; ///
	da_lua_rawgetp lua_rawgetp; ///
	da_lua_createtable lua_createtable; ///
	da_lua_newuserdata lua_newuserdata; ///
	da_lua_getmetatable lua_getmetatable; ///
	da_lua_getuservalue lua_getuservalue; ///
	da_lua_setglobal lua_setglobal; ///
	da_lua_settable lua_settable; ///
	da_lua_setfield lua_setfield; ///
	da_lua_rawset lua_rawset; ///
	da_lua_rawseti lua_rawseti; ///
	da_lua_rawsetp lua_rawsetp; ///
	da_lua_setmetatable lua_setmetatable; ///
	da_lua_setuservalue lua_setuservalue; ///
	da_lua_callk lua_callk; ///
	da_lua_pcallk lua_pcallk; ///
	da_lua_load lua_load; ///
	da_lua_dump lua_dump; ///
	da_lua_yieldk lua_yieldk; ///
	da_lua_resume lua_resume; ///
	da_lua_status lua_status; ///
	da_lua_isyieldable lua_isyieldable; ///
	da_lua_gc lua_gc; ///
	da_lua_error lua_error; ///
	da_lua_next lua_next; ///
	da_lua_concat lua_concat; ///
	da_lua_len lua_len; ///
	da_lua_stringtonumber lua_stringtonumber; ///
	da_lua_getallocf lua_getallocf; ///
	da_lua_setallocf lua_setallocf; ///
	da_lua_getstack lua_getstack; ///
	da_lua_getinfo lua_getinfo; ///
	da_lua_getlocal lua_getlocal; ///
	da_lua_setlocal lua_setlocal; ///
	da_lua_getupvalue lua_getupvalue; ///
	da_lua_setupvalue lua_setupvalue; ///
	da_lua_upvalueid lua_upvalueid; ///
	da_lua_upvaluejoin lua_upvaluejoin; ///
	da_lua_sethook lua_sethook; ///
	da_lua_gethook lua_gethook; ///
	da_lua_gethookmask lua_gethookmask; ///
	da_lua_gethookcount lua_gethookcount; ///
	da_luaL_checkversion_ luaL_checkversion_; ///
	da_luaL_getmetafield luaL_getmetafield; ///
	da_luaL_callmeta luaL_callmeta; ///
	da_luaL_tolstring luaL_tolstring; ///
	da_luaL_argerror luaL_argerror; ///
	da_luaL_checklstring luaL_checklstring; ///
	da_luaL_optlstring luaL_optlstring; ///
	da_luaL_checknumber luaL_checknumber; ///
	da_luaL_optnumber luaL_optnumber; ///
	da_luaL_checkinteger luaL_checkinteger; ///
	da_luaL_optinteger luaL_optinteger; ///
	da_luaL_checkstack luaL_checkstack; ///
	da_luaL_checktype luaL_checktype; ///
	da_luaL_checkany luaL_checkany; ///
	da_luaL_newmetatable luaL_newmetatable; ///
	da_luaL_setmetatable luaL_setmetatable; ///
	da_luaL_testudata luaL_testudata; ///
	da_luaL_checkudata luaL_checkudata; ///
	da_luaL_where luaL_where; ///
	da_luaL_error luaL_error; ///
	da_luaL_checkoption luaL_checkoption; ///
	da_luaL_fileresult luaL_fileresult; ///
	da_luaL_execresult luaL_execresult; ///
	da_luaL_ref luaL_ref; ///
	da_luaL_unref luaL_unref; ///
	da_luaL_loadfilex luaL_loadfilex; ///
	da_luaL_loadbufferx luaL_loadbufferx; ///
	da_luaL_loadstring luaL_loadstring; ///
	da_luaL_newstate luaL_newstate; ///
	da_luaL_len luaL_len; ///
	da_luaL_gsub luaL_gsub; ///
	da_luaL_setfuncs luaL_setfuncs; ///
	da_luaL_getsubtable luaL_getsubtable; ///
	da_luaL_traceback luaL_traceback; ///
	da_luaL_requiref luaL_requiref; ///
	da_luaL_buffinit luaL_buffinit; ///
	da_luaL_prepbuffsize luaL_prepbuffsize; ///
	da_luaL_addlstring luaL_addlstring; ///
	da_luaL_addstring luaL_addstring; ///
	da_luaL_addvalue luaL_addvalue; ///
	da_luaL_pushresult luaL_pushresult; ///
	da_luaL_pushresultsize luaL_pushresultsize; ///
	da_luaL_buffinitsize luaL_buffinitsize; ///
	da_luaL_pushmodule luaL_pushmodule; ///
	da_luaL_openlib luaL_openlib; ///
	da_luaopen_base luaopen_base; ///
	da_luaopen_coroutine luaopen_coroutine; ///
	da_luaopen_table luaopen_table; ///
	da_luaopen_io luaopen_io; ///
	da_luaopen_os luaopen_os; ///
	da_luaopen_string luaopen_string; ///
	da_luaopen_utf8 luaopen_utf8; ///
	da_luaopen_bit32 luaopen_bit32; ///
	da_luaopen_math luaopen_math; ///
	da_luaopen_debug luaopen_debug; ///
	da_luaopen_package luaopen_package; ///
	da_luaL_openlibs luaL_openlibs; ///
}
