#!/usr/bin/env bash

echo "Building using Flutter"

set -x

# Install dart from .deb
apt-get -q -y install apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
  | sudo gpg  --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=armhf] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' \
  | sudo tee /etc/apt/sources.list.d/dart_stable.list
#sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
#sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
apt-get -q -y update
apt-get -q -y install dart


git clone https://github.com/flutter/flutter.git -b stable
cd flutter
git clean -xfd
#git stash save --keep-index
#git stash drop
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

