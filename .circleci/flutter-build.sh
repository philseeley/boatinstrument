#!/usr/bin/env bash

echo "Building using Flutter"

set -x

LMARCH="$(dpkg --print-architecture)"
export LMARCH
  
if [ "$LMARCH" == 'armhf' ]; then
  # Install dart 
  #wget https://gsdview.appspot.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-arm-release.zip
  wget https://gsdview.appspot.com/dart-archive/channels/stable/release/3.4.4/sdk/dartsdk-linux-arm-release.zip
  unzip dartsdk-linux-arm-release.zip
  ./dart-sdk/bin/dart --version
  export PATH="$PATH:`pwd`/dart-sdk/bin"
fi

git clone --depth 1 --branch 3.22.1 https://github.com/flutter/flutter
#cd flutter
#git clean -xfd
#git pull
#cd ..

export PATH="$PATH:`pwd`/flutter/bin"

if [ "$LMARCH" == 'armhf' ]; then
  #apt-get -q -y install libarchive-dev 
  flutter doctor -v || true
  rm -rf `pwd`/flutter/bin/cache/dart-sdk/
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

