#!/usr/bin/env bash

test_project_path='./testerino-crossplatform/testerino-crossplatform.xcodeproj'
test_project_name='Essayist'

killall Simulator
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
open -a Simulator.app
sleep 2
osascript -e 'tell application "Simulator" to activate'
osascript -e 'tell application "System Events" to keystroke "k" using {command down, shift down}'
osascript -e 'tell application "System Events" to keystroke "k" using {command down, shift down}'
xcodebuild test -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 11' -scheme '$test_project_name (iOS)' -project $testerino_project_path
killall Simulator
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool true

# xcodebuild test -sdk macosx11.0 -destination 'platform=OS X,arch=x86_64' -scheme '$test_project_name (macOS)' -project $testerino_project_path
