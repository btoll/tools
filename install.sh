#!/bin/bash
# Installation script for custom CLI tools.

echo "$(tput setaf 2)[INFO]$(tput sgr0) Creating symbolic links for tools..."

ln -s "$PWD"/bash/bootstrap.sh /usr/local/bin/bootstrap
ln -s "$PWD"/bash/check-dependencies.sh /usr/local/bin/check-dependencies
ln -s "$PWD"/bash/encrypt.sh /usr/local/bin/encrypt
ln -s "$PWD"/bash/get_fiddle.sh /usr/local/bin/get_fiddle
ln -s "$PWD"/bash/make_file.sh /usr/local/bin/make_file
ln -s "$PWD"/bash/make_ticket.sh /usr/local/bin/make_ticket
ln -s "$PWD"/tmux/tmuxly.sh /usr/local/bin/tmuxly

# Python3 build compression tools.
ln -s "$PWD"/python3/server.py /usr/local/bin/server.py
ln -s "$PWD"/python3/build/css_compress.py /usr/local/bin/css_compress.py
ln -s "$PWD"/python3/build/js_compress.py /usr/local/bin/js_compress.py
export PYTHONPATH=$PYTHONPATH:/usr/local/bin/
echo -e "The location of the Python3 build tools has been added to your PYTHONPATH for this terminal session.\nHowever, it's highly recommended to put the following in your .bashrc:\n\n\texport PYTHONPATH=\$PYTHONPATH:/usr/local/bin/"

echo
echo "$(tput setaf 2)[INFO]$(tput sgr0) Installation complete."

