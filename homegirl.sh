#!/bin/bash
cd "$(dirname "$0")"

if [ "$(uname)" == "Darwin" ]; then
  ./homegirl_macos && rm ./install_dependencies.sh
else
  ./homegirl_linux && rm ./install_dependencies.sh
fi
if [ -f ./install_dependencies.sh ]; then
  if [ "$(uname)" == "Darwin" ]; then
    open -a Terminal ./install_dependencies.sh
  else
    x-terminal-emulator -e ./install_dependencies.sh
  fi
fi
