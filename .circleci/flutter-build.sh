#!/usr/bin/env bash

echo "Building using Flutter"

echo "To match flutter and dart versions see: https://docs.flutter.dev/release/archive"

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

git clone --depth 1 --branch 3.22.3 https://github.com/flutter/flutter

export PATH="$PATH:`pwd`/flutter/bin"

if [ "$LMARCH" == 'armhf' ]; then
  flutter doctor -v || true
  rm -rf `pwd`/flutter/bin/cache/dart-sdk/
  mkdir -p `pwd`/flutter/bin/cache/dart-sdk/
  cp -r `pwd`/dart-sdk/* `pwd`/flutter/bin/cache/dart-sdk/
  file `pwd`/flutter/bin/cache/dart-sdk/bin/dart
  ls -l  `pwd`/flutter/bin/cache/artifacts/engine/
else
  flutter doctor -v
fi

cd ..

flutter build linux
cpu=$LMARCH
cd build/linux/${cpu:0:1}*/release
mv bundle boatinstrument
tar czf "${package_dir}"/${name}-${type}-${cpu}.tgz boatinstrument

ls -ltr build/linux/*/release/boatinstrument/*
pwd
ls -ltr packages/*

