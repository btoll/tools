#!/bin/bash

set -e

BINDIR="$HOME/bin"
mkdir -p "$BINDIR"

for bin in {htoi,itob,otoi}
do
    gcc -o "$BINDIR/$bin" "$bin.c"
done

cd asbits || exit
gcc -o "$BINDIR/asbits" asbits.c

echo "[SUCCESS] Installed binaries to $BINDIR"

