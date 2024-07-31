#!/usr/bin/env bash

echo "Building using Flutter"

set -x

LMARCH="$(dpkg --print-architecture)"
export LMARCH
  
if [ "$LMARCH" == 'armhf' ]; then
  # Install dart 
  wget https://gsdview.appspot.com/dart-archive/channels/dev/release/latest/sdk/dartsdk-linux-arm-release.zip
  unzip dartsdk-linux-arm-release.zip
  ./dart-sdk/bin/dart --version
  export PATH="$PATH:`pwd`/dart-sdk/bin"
fi

git clone https://github.com/flutter/flutter.git -b stable
cd flutter
git clean -xfd
git pull
cd ..

export PATH="$PATH:`pwd`/flutter/bin"

if [ "$LMARCH" == 'armhf' ]; then
  cp -r `pwd`/dart-sdk `pwd`/flutter/bin/cache/
fi

flutter doctor

cd ..

chmod +x ./package
./package linux

ls -ltr build/linux/*/release/boatinstrument/*
pwd
ls -ltr packages/*

