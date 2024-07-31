#!/usr/bin/env bash

echo "Publishing"

set -x

git clone https://github.com/flutter/flutter.git -b stable

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor

cd ..
flutter build linux --release

ls -ltr build/linux/arm64/release/bundle/*
