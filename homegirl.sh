#!/bin/bash
cd "$(dirname "$0")"

if [ "$(uname)" == "Darwin" ]; then
  ./homegirl_macos || open -a Terminal ./install_dependencies.sh
else
  ./homegirl_linux || (test -f ./install_dependencies.sh && (x-terminal-emulator -e ./install_dependencies.sh || gnome-terminal -e ./install_dependencies.sh || xterm -e ./install_dependencies.sh))
fi
