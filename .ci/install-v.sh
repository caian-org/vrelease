#!/bin/bash

set -e

VLANG_TARGET_OS=""
VLANG_VERSION="0.2.2"

case "$TRAVIS_OS_NAME" in
    osx) VLANG_TARGET_OS="macos" ;;
    linux) VLANG_TARGET_OS="linux" ;;
    windows) VLANG_TARGET_OS="windows" ;;
esac

FN="v_${VLANG_TARGET_OS}.zip"
URL="https://github.com/vlang/v/releases/download/${VLANG_VERSION}/${FN}"

echo "Downloading from: $URL"

(
    cd /tmp
    wget -q "$URL"
    unzip -q "$FN"

    echo "Path: $PATH"

    cd v
    ./v up

    if [ "$VLANG_TARGET_OS" = "macos" ];   then ./v symlink; fi
    if [ "$VLANG_TARGET_OS" = "windows" ]; then ./v symlink; fi
    if [ "$VLANG_TARGET_OS" = "linux" ];   then sudo ./v symlink; fi
)

v version
