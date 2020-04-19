#!/bin/bash
apidoc="system_drive/docs/core/overview.md"
echo '# Lua API overview' > $apidoc
echo '[See docs for details.](./)' >> $apidoc

for pack in ./source/lua_api/*.d; do
  echo "## " $(basename $pack .d) >> $apidoc
  cat $pack | grep /// | while  read _ line; do
    echo "   " $line >> $apidoc
  done
done