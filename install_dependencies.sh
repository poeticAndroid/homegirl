#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
  echo "This script will install dependencies for Homegirl on MacOS using Homebrew."
  echo "Press [Enter] to continue or [Ctrl+C] to cancel."
  read enter

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew install sdl2 freeimage lua && rm "$0"
else
  echo "This script will install dependencies for Homegirl on Ubuntu and Fedora based Linux distros."
  echo "Press [Enter] to continue or [Ctrl+C] to cancel."
  read enter

  (
    sudo apt-get install libsdl2-2.0-0 libfreeimage3 liblua5.3-dev curl ||
    (
      sudo dnf install SDL2 freeimage lua curl # &&
      # sudo ln -s /usr/lib64/liblua-5.3.so /usr/lib64/liblua5.3.so
    )
  ) && rm "$0"
fi
