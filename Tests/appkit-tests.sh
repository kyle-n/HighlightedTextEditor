#!/usr/bin/env bash

test_project_path='./Essayist/Essayist.xcodeproj'
test_project_name='Essayist'

# Make script able to run from any directory
script_dirname=$(dirname "$0")
cd $script_dirname

xcodebuild -resolvePackageDependencies
xcodebuild test -sdk macosx11.0 -destination 'platform=OS X,arch=x86_64' -scheme "$test_project_name (macOS)" -project $test_project_path
