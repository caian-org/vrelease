#!/bin/bash

set -e

source ~/.rvm/scripts/rvm && rvm use 2.7.2 --install --binary
gem install bundler

brew install openssl
