#!/bin/bash

set -e
mkdir $BUILD_DIR/build
rsync -r --verbose --exclude 'node_modules' $APP_DIR/* $BUILD_DIR/build
