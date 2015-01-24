#!/bin/bash

# Note it's really better to use an alias than a script.
# For example:

#     alias bootstrap='pushd $SDK5/ext; sencha ant bootstrap; popd'
#

BOOTSTRAP_DIR=${BOOTSTRAP_LOCATION:-/usr/local/www/SDK5/ext/}

cd $BOOTSTRAP_DIR
sencha ant bootstrap
cd -

