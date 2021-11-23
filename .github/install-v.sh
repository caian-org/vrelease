#!/bin/bash

set -e

VLANG_TARGET_OS=""
VLANG_VERSION="weekly.2021.46"

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
    curl -L -O "$URL"
    unzip -q "$FN"
    printf "\n\n"

    cd v
    ./v up

    if [ "$VLANG_TARGET_OS" = "windows" ]; then ./make.bat -msvc; fi
)

printf "\n\n"
v version
printf "\n"
