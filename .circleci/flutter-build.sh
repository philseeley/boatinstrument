#!/usr/bin/env bash

echo "Building using Flutter"

set -x

git clone https://github.com/flutter/flutter.git -b stable

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor

cd ..
#flutter build linux --release

chmod +x ./package
./package linux

ls -ltr build/linux/*/release/bundle/*
