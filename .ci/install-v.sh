#!/bin/bash

set -e

VLANG_TARGET_OS=""
VLANG_VERSION="0.2.2"

case "$TRAVIS_OS_NAME" in
    osx) VLANG_TARGET_OS="macos" ;;
    linux) VLANG_TARGET_OS="linux" ;;
esac

FN="v_${VLANG_TARGET_OS}.zip"
URL="https://github.com/vlang/v/releases/download/${VLANG_VERSION}/${FN}"

echo "Downloading from: $URL"

(
    cd /tmp
    wget -q "$URL"
    unzip -q "$FN"

    cd v
    ./v up

    if [ "$VLANG_TARGET_OS" = "macos" ]; then ./v symlink; fi

    # for some reason, "symlink" doesn't work properly on *ANY* version of ubuntu
    # that's why i'm symlinking "manually"
    if [ "$VLANG_TARGET_OS" = "linux" ]; then sudo ln -s /tmp/v/v ~/bin; fi
)

v version
