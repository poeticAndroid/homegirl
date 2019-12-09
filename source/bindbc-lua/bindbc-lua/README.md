# bindbc-lua
This project provides both static and dynamic bindings to the C API of [Lua programming language](http://www.glfw.org/index.html). The bindings are `@nogc` and `nothrow` compatible and can be compiled for compatibility with `-betterC`. This package is intended as a replacement of [DerelictLua](https://github.com/DerelictOrg/DerelictLua), which is not compatible with `@nogc`,  `nothrow`, or `-betterC`.

## Usage
By default, `bindbc-lua` is configured to compile as a dynamic binding that is not `-betterC` compatible. The dynamic binding has no link-time dependency on the Lua library, so the Lua shared library must be manually loaded at runtime. When configured as a static binding, there is a link-time dependency on the lua library through either the static library or the appropriate file for linking with shared libraries on your platform (see below).

When using DUB to manage your project, the static binding can be enabled via a DUB `subConfiguration` statement in your project's package file. `-betterC` compatibility is also enabled via subconfigurations.

To use Lua, add `bindbc-lua` as a dependency to your project's package config file. For example, the following is configured to use Lua as a dynamic binding that is not `-betterC` compatible:

__dub.json__
```
dependencies {
    "bindbc-lua": "~>0.1.0",
}
```

__dub.sdl__
```
dependency "bindbc-lua" version="~>0.1.0"
```

### The dynamic binding
The dynamic binding requires no special configuration when using DUB to manage your project. There is no link-time dependency. At runtime, the Lua shared library is required to be on the shared library search path of the user's system. On Windows, this is typically handled by distributing the Lua DLL with your program. On other systems, it usually means the user must install the Lua library through a package manager.

To load the shared library, you need to call the `loadLua` function. This returns a member of the `LuaSupport` enumeration (See [the README for `bindbc.loader`](https://github.com/BindBC/bindbc-loader/blob/master/README.md) for the error handling API):

* `LuaSupport.noLibrary` indicating that the library failed to load (it couldn't be found)
* `LuaSupport.badLibrary` indicating that one or more symbols in the library failed to load
* a member of `LuaSupport` indicating a version number that matches the version of Lua that `bindbc-lua` was configured at compile-time to load. Unlike other BindBC packages, which tend to load the lowest version of a library by default, `binbc-lua` __must__ be configured to load a specific version of the Lua library via a version identifier (see below). This value will match the global manifest constant, `luaSupport`.

```d
import bindbc.glfw;

/*
This version attempts to load the lua shared library using well-known variations
of the library name for the host system.
*/
LuaSupport ret = loadLua();
if(ret != luaSupport) {

    // Handle error. For most use cases, its reasonable to use the the error handling API in
    // bindbc-loader to retrieve error messages for logging and then abort. If necessary, it's
    // possible to determine the root cause via the return value:

    if(ret == luaSupport.noLibrary) {
        // Lua shared library failed to load
    }
    else if(luaSupport.badLibrary) {
        // One or more symbols failed to load. The likely cause is that the
        // shared library is a version different from the one the app was
        // configured to load
    }
}
/*
This version attempts to load the GLFW library using a user-supplied file name.
Usually, the name and/or path used will be platform specific, as in this example
which attempts to load `lua51.dll` from the `libs` subdirectory, relative
to the executable, only on Windows.
*/
// version(Windows) loadLua("libs/lua51.dll")
```
Because of the number of changes to Lua's C API between releases, `bindbc-lua` does not attempt to load any version by default as there is no version of the API that is shared by all supported versions of Lua. A specific version of Lua must be specified via the `-version` compiler switch or the `versions` DUB directive with the desired Lua version number. In this example, the GLFW dynamic binding is compiled to support Lua 5.1:

__dub.json__
```
"dependencies": {
    "bindbc-lua": "~>0.1.0"
},
"versions": ["LUA_51"]
```

__dub.sdl__
```
dependency "bindbc-lua" version="~>0.1.0"
versions "LUA_51"
```

With this example configuration, `luaSupport == LuaSupport.lua51`. If GLFW 5.1 is installed on the user's system, `loadLua` will return `LuaSupport.lua51`. If no compatible version of Lua is installed, `loadLua` will return `GLFWSupport.noLibrary`. The `bindbc-loader` always attempts to load shared libraries with a version number in the name. If the user attempts to load the Lua shared library via an alternative name, it is possible that the binding's configured version and the shared library's actual version do not match, in which case the return value will be `luaSupport.badLibrary`.

The global property `loadedLuaVersion` is an alternative means of testing the result of `loadLua`. With other BindBC bindings, it is possible to load a lower version of a library than the one the binding was configured to load, in which case the global property will indicate the loaded version when the loader returns `badLibrary`. This is not possible in `bindbc-lua`. `loadedLuaVersion` is set to `luaSupport.noLibrary` before `loadLua` is called. When the function returns, `loadedLuaVersion` will be set to the same value as its return value.

The function `isLuaLoaded` returns `true` if the configured version of Lua has been loaded and `false` otherwise.

Following are the supported versions of Lua, the corresponding version IDs to pass to the compiler, and the corresponding `LuaSupport` members.

| Library & Version  | Version ID       | `LuaSupport` Member |
|--------------------|------------------|---------------------|
|Lua 5.1             | LUA_51           | `LuaSupport.lua51`  |
|Lua 5.2             | LUA_52           | `LuaSupport.lua52`  |
|Lua 5.3             | LUA_53           | `LuaSupport.lua53`  |

## The static binding
The static binding has a link-time dependency on either the shared or the static Lua library. On Windows, you can link with the static library or, to use the shared library with the import library. On other systems, you can link with either the static library or directly with the shared library. This requires the Lua development package be installed on your system at compile time, either by compiling the Lua source yourself, downloading the Lua precompiled binaries for Windows, or installing via a system package manager.

When linking with the static library, there is no runtime dependency on Lua. When linking with the shared library (or the import library on Windows), the runtime dependency is the same as the dynamic binding, the difference being that the shared library is no longer loaded manually---loading is handled automatically by the system when the program is launched.

Enabling the static binding can be done in two ways.

### Via the compiler's `-version` switch or DUB's `versions` directive
Pass the `BindLua_Static` version to the compiler and link with the appropriate library. Note that `BindLua_Static` will also enable the static binding for any satellite libraries used.

When using the compiler command line or a build system that doesn't support DUB, this is the only option. The `-version=BindLua_Static` option should be passed to the compiler when building your program. All of the required C libraries, as well as the `bindbc-lua` and `bindbc-loader` static libraries must also be passed to the compiler on the command line or via your build system's configuration.

When using DUB, its `versions` directive is an option. For example, when using the static binding and Lua 5.1:

__dub.json__
```
"dependencies": {
    "bindbc-lua": "~>0.1.0"
},
"versions": ["BindLua_Static", "LUA_51"],
"libs": ["lua5.1"]
```

__dub.sdl__
```
dependency "bindbc-lua" version="~>0.1.0"
versions "BindLua_Static" "LUA_5.1"
libs "lua5.1"
```

### Via DUB subconfigurations
Instead of using DUB's `versions` directive, a `subConfiguration` can be used. Enable the `static` subconfiguration for the `bindbc-lua` dependency:

__dub.json__
```
"dependencies": {
    "bindbc-lua": "~>0.1.0"
},
"subConfigurations": {
    "bindbc-lua": "static"
},
"versions": ["LUA_51"],
"libs": ["lua5.1"]
```

__dub.sdl__
```
dependency "bindbc-lua" version="~>0.1.0"
subConfiguration "bindbc-lua" "static"
versions "LUA_51"
libs "lua5.1"
```

This has the benefit that it completely excludes from the build any source modules related to the dynamic binding, i.e. they will never be passed to the compiler.

## `betterC` support

`betterC` support is enabled via the `dynamicBC` and `staticBC` subconfigurations, for dynamic and static bindings respectively. To enable the static binding with `-betterC` support:

__dub.json__
```
"dependencies": {
    "bindbc-lua": "~>0.1.0"
},
"subConfigurations": {
    "bindbc-lua": "staticBC"
},
"versions": ["LUA_51"],
"libs": ["lua5.1"]
```

__dub.sdl__
```
dependency "bindbc-lua" version="~>0.5.0"
subConfiguration "bindbc-lua" "staticBC"
versions "LUA_51"
libs "lua5.1"
```

When not using DUB to manage your project, first use DUB to compile the BindBC libraries with the `dynamicBC` or `staticBC` configuration, then pass `-betterC` to the compiler when building your project.