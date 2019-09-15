#!/bin/bash
echo "This script will install dependencies for Homegirl on Ubuntu based Linux distros."
echo "Press [Enter] to continue or [Ctrl+C] to cancel."
read enter

sudo apt-get install libsdl2-2.0-0 libfreeimage3 liblua5.3-dev curl 
