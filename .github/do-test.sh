#!/bin/bash

set -ex

git checkout tests

# ....
./committer
./vrelease

# ....
./committer
./vrelease -d

# ....
./committer
./vrelease -l 5

# ....
./committer
./vrelease -d -n

# ....
./committer
./vrelease -a committer

# ....
./committer
./vrelease -a committer -a vrelease -d -l 8
