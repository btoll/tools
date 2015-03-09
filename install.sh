#!/bin/bash
# Installation script for custom CLI tools.

echo "[Install] Creating symbolic links for utils..."
echo
pushd utils
ln -s "$PWD"/bootstrap.sh /usr/local/bin/bootstrap
ln -s "$PWD"/check-dependencies.sh /usr/local/bin/check-dependencies
ln -s "$PWD"/get-fiddle.sh /usr/local/bin/get-fiddle
ln -s "$PWD"/make_file.sh /usr/local/bin/make_file
ln -s "$PWD"/make_ticket.sh /usr/local/bin/make_ticket

# https://github.com/btoll/utils/tree/master/tmux
ln -s "$PWD"/tmux/tmuxly.sh /usr/local/bin/tmuxly
popd

echo
echo "[Install] Installation complete."

