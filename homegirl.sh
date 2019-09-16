#!/bin/bash
cd "$(dirname "$0")"

if [ -f ./install_dependencies.sh ]; then
  if [ "$(uname)" == "Darwin" ]; then
    open -a Terminal ./install_dependencies.sh
  else
    x-terminal-emulator -e ./install_dependencies.sh
  fi
else
  if [ "$(uname)" == "Darwin" ]; then
    ./homegirl_macos
  else
    ./homegirl_linux
  fi
fi