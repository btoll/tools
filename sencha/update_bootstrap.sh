#!/bin/bash
BOOTSTRAP_DIR=${BOOTSTRAP_LOCATION:-/usr/local/www/SDK5/ext/}

cd $BOOTSTRAP_DIR
sencha ant bootstrap
cd -

