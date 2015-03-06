#!/bin/bash

usage() {
    echo "Installation script for custom CLI tools."
    echo
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo "--prefix  The location where the utils remote repository will be cloned."
    echo "          Defaults to CWD."
}

while [ "$#" -gt 0 ]; do
    OPT="$1"
    case $OPT in
        --help|-help|-h) usage; exit 0 ;;
        --prefix) shift; UTILS=$(echo $1 | tr -d '\r') ;;
    esac
    shift
done

# https://github.com/btoll/utils
if [ -n "$UTILS" ]; then
    pushd "$UTILS" > /dev/null
fi

echo "[Install] Cloning remote 'utils' repository into $UTILS."
echo
git clone git@github.com:btoll/utils.git

echo "[Install] Creating symbolic links for utils..."
echo
cd utils
ln -s "$PWD"/bootstrap.sh /usr/local/bin/bootstrap
ln -s "$PWD"/check-dependencies.sh /usr/local/bin/check-dependencies
ln -s "$PWD"/get-fiddle.sh /usr/local/bin/get-fiddle
ln -s "$PWD"/make_file.sh /usr/local/bin/make_file
ln -s "$PWD"/make_ticket.sh /usr/local/bin/make_ticket

# https://github.com/btoll/utils/tree/master/tmux
ln -s "$PWD"/tmux/tmuxly.sh /usr/local/bin/tmuxly
cd -

if [ -n "$UTILS" ]; then
    popd > /dev/null
fi

echo
echo "[Install] Installation complete."

