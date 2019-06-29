#!/bin/bash

echo '# Lua API overview' > api.md

for pack in ./source/lua_api/*.d; do
  echo "## " $(basename $pack .d) >> api.md
  cat $pack | grep /// | while  read _ line; do
    echo "   " $line >> api.md
  done
done