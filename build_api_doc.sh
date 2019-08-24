#!/bin/bash

echo '# Lua API overview' > api.md
echo '[See wiki for details.](https://github.com/poeticAndroid/homegirl/wiki)' >> api.md

for pack in ./source/lua_api/*.d; do
  echo "## " $(basename $pack .d) >> api.md
  cat $pack | grep /// | while  read _ line; do
    echo "   " $line >> api.md
  done
done