#!/bin/bash

echo "$(tput setaf 2)[INFO]$(tput sgr0) Removing symbolic links for utils..."
echo
rm /usr/local/bin/bootstrap
rm /usr/local/bin/check-dependencies
rm /usr/local/bin/encrypt
rm /usr/local/bin/get-fiddle
rm /usr/local/bin/make_file
rm /usr/local/bin/make_ticket
rm /usr/local/bin/tmuxly
rm /usr/local/bin/server.py
rm /usr/local/bin/css_compress.py
rm /usr/local/bin/js_compress.py

echo
echo "$(tput setaf 2)[INFO]$(tput sgr0) Uninstall complete."

