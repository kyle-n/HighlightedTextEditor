#!/usr/bin/env bash

# Make script able to run from any directory
script_dirname=$(dirname "$0")
cd $script_dirname

./uikit-tests.sh
./appkit-tests.sh
