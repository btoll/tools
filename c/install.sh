#!/bin/bash

BINDIR="$HOME/bin"

if [ ! -d "$BINDIR" ]
then
    mkdir "$BINDIR"
fi

gcc -o "$BINDIR/htoi" htoi.c
gcc -o "$BINDIR/itob" itob.c
gcc -o "$BINDIR/otoi" otoi.c

cd asbits || exit
gcc -o "$BINDIR/asbits" asbits.c

