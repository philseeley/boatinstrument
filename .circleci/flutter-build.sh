#!/usr/bin/env bash

echo "Building using Flutter"
echo "To match flutter and dart versions see: https://docs.flutter.dev/release/archive"

set -x

LMARCH="$(dpkg --print-architecture)"
export LMARCH

git clone --depth 1 --branch 3.24.3 https://github.com/flutter/flutter

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor -v

cd ..

type=$1; shift
name=boatinstrument-$(awk '/^version:/ {print $2}' pubspec.yaml)

mkdir -p packages
package_dir=$(pwd)/packages

case ${type} in
  linux)
    flutter build -v $type
    cpu=$(uname -m)
    cd build/linux/${cpu:0:1}*/release
    mv bundle boatinstrument
    tar czf "${package_dir}"/${name}-${type}-${cpu}.tgz boatinstrument
    ;;
  flutterpi_arm64)
    flutter pub global activate flutterpi_tool
    export PATH="$PATH":"$HOME/.pub-cache/bin"
    flutter pub get
    flutterpi_tool build --arch=arm64 --cpu=pi4 --release
    cd build/
    mv flutter_assets boatinstrument
    tar czf "${package_dir}"/${name}-${type}.tgz boatinstrument
    ;;
  flutterpi_arm32)
    flutter pub global activate flutterpi_tool
    export PATH="$PATH":"$HOME/.pub-cache/bin"
    flutter pub get
    flutterpi_tool build --release
    cd build/
    mv flutter_assets boatinstrument
    tar czf "${package_dir}"/${name}-${type}.tgz boatinstrument
    ;;
  *)
    echo "Unknown type '$type'"
esac



