#!/bin/bash
# Installation script for custom CLI tools.

echo "$(tput setaf 2)[INFO]$(tput sgr0) Installing workflow tools..."

ln -s "$PWD"/bash/bootstrap.sh /usr/local/bin/bootstrap
ln -s "$PWD"/bash/check-dependencies.sh /usr/local/bin/check-dependencies
ln -s "$PWD"/bash/get_fiddle.sh /usr/local/bin/get_fiddle
ln -s "$PWD"/bash/make_file.sh /usr/local/bin/make_file
ln -s "$PWD"/bash/make_ticket.sh /usr/local/bin/make_ticket
ln -s "$PWD"/tmux/tmuxly.sh /usr/local/bin/tmuxly

echo "$(tput setaf 2)[INFO]$(tput sgr0) Installing Python build tools..."

ln -s "$PWD"/python3/server.py /usr/local/bin/server.py
ln -s "$PWD"/python3/build/base_compress.py /usr/local/bin/base_compress.py
ln -s "$PWD"/python3/build/css_compress.py /usr/local/bin/css_compress.py
ln -s "$PWD"/python3/build/js_compress.py /usr/local/bin/js_compress.py
ln -s "$PWD"/python3/build/build.py /usr/local/bin/build.py
ln -s "$PWD"/python3/build/crypt.py /usr/local/bin/crypt.py

if [ -f ~/.bashrc ]; then
    echo "export PYTHONPATH=\$PYTHONPATH:/usr/local/bin/" >> ~/.bashrc
    . ~/.bashrc
else if [ -f ~/.bash_profile ]; then
    echo "export PYTHONPATH=\$PYTHONPATH:/usr/local/bin/" >> ~/.bash_profile
    . ~/.bash_profile
else
    export PYTHONPATH=$PYTHONPATH:/usr/local/bin/
    echo -e "The location of the Python3 build tools has been added to your PYTHONPATH for this terminal session.\nHowever, it's highly recommended to put the following in one of your shell's login scripts:\n\n\texport PYTHONPATH=\$PYTHONPATH:/usr/local/bin/"
fi

echo
echo "$(tput setaf 2)[INFO]$(tput sgr0) Installation complete."

