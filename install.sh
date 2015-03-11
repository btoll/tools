#!/bin/bash
# Installation script for custom CLI tools.

echo "[Install] Creating symbolic links for utils..."

ln -s "$PWD"/bootstrap.sh /usr/local/bin/bootstrap
ln -s "$PWD"/check-dependencies.sh /usr/local/bin/check-dependencies
ln -s "$PWD"/get_fiddle.sh /usr/local/bin/get_fiddle
ln -s "$PWD"/make_file.sh /usr/local/bin/make_file
ln -s "$PWD"/make_ticket.sh /usr/local/bin/make_ticket

# https://github.com/btoll/utils/tree/master/tmux
ln -s "$PWD"/tmux/tmuxly.sh /usr/local/bin/tmuxly

echo
echo "[Install] Installation complete."

