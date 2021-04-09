#!/bin/bash

set -e

VLANG_TARGET_OS=""
VLANG_VERSION="0.2.2"

case "$OS" in
    macos-latest) VLANG_TARGET_OS="macos" ;;
    ubuntu-latest) VLANG_TARGET_OS="linux" ;;
    windows-latest) VLANG_TARGET_OS="windows" ;;
esac

FN="v_${VLANG_TARGET_OS}.zip"
URL="https://github.com/vlang/v/releases/download/${VLANG_VERSION}/${FN}"

echo "Downloading from: $URL"

(
    cd /tmp
    curl -q -L -O "$URL"
    unzip -q "$FN"

    cd v
    ./v up
)

v version
