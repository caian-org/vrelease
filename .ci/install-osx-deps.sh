#!/bin/sh

set -e

rvm use 2.7.2 --install --binary
gem install bundler

brew bundle --verbose --global
brew install openssl
