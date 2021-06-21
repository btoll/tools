#!/bin/bash

BINDIR="$HOME/bin"
mkdir "$BINDIR"

gcc -o "$BINDIR" htoi.c
gcc -o "$BINDIR" itob.c
gcc -o "$BINDIR" otoi.c

cd asbits || exit
gcc -o "$BINDIR" asbits.c

