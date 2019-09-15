#!/bin/bash
echo "This script will install dependencies for Homegirl on MacOS using Homebrew."
echo "Press [Enter] to continue or [Ctrl+C] to cancel."
read enter

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install sdl2
brew install freeimage
brew install lua

