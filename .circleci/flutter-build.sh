#!/usr/bin/env bash

echo "Building using Flutter"

set -x

git clone https://github.com/flutter/flutter.git -b stable
cd flutter
git clean -xfd
git stash save --keep-index
git stash drop
git pull
cd ..

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor

cd ..

#flutter build linux --release
#ls -ltr build/linux/*/release/bundle/*

chmod +x ./package
./package linux

ls -ltr build/linux/*/release/boatinstrument/*
pwd
ls -ltr
ls -ltr packages/*

