#!/usr/bin/env bash

echo "Building using Flutter"

echo "To match flutter and dart versions see: https://docs.flutter.dev/release/archive"

set -x

LMARCH="$(dpkg --print-architecture)"
export LMARCH
  
if [ "$LMARCH" == 'armhf' ]; then
  # Install dart 
  #wget https://gsdview.appspot.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-arm-release.zip
  wget https://gsdview.appspot.com/dart-archive/channels/stable/release/3.4.0/sdk/dartsdk-linux-arm-release.zip
  unzip dartsdk-linux-arm-release.zip
  ./dart-sdk/bin/dart --version
  export PATH="$PATH:`pwd`/dart-sdk/bin"
fi

git clone --depth 1 --branch 3.22.0 https://github.com/flutter/flutter

export PATH="$PATH:`pwd`/flutter/bin"

if [ "$LMARCH" == 'armhf' ]; then
  flutter doctor -v || true
  #rm -rf `pwd`/flutter/bin/cache/dart-sdk/
  mkdir -p `pwd`/flutter/bin/cache/dart-sdk/
  cp -r `pwd`/dart-sdk/* `pwd`/flutter/bin/cache/dart-sdk/
  file `pwd`/flutter/bin/cache/dart-sdk/bin/dart
else
  flutter doctor -v
fi

cd ..

chmod +x ./package
./package linux

ls -ltr build/linux/*/release/boatinstrument/*
pwd
ls -ltr packages/*

