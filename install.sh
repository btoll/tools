#!/bin/bash
# Installation script for custom CLI tools.

echo "[Install] Creating symbolic links for tools..."

ln -s "$PWD"/bash/bootstrap.sh /usr/local/bin/bootstrap
ln -s "$PWD"/bash/check-dependencies.sh /usr/local/bin/check-dependencies
ln -s "$PWD"/bash/get_fiddle.sh /usr/local/bin/get_fiddle
ln -s "$PWD"/bash/make_file.sh /usr/local/bin/make_file
ln -s "$PWD"/bash/make_ticket.sh /usr/local/bin/make_ticket

# https://github.com/btoll/utils/tree/master/tmux
ln -s "$PWD"/tmux/tmuxly.sh /usr/local/bin/tmuxly

echo
echo "[Install] Installation complete."

