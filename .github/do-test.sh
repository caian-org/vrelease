#!/bin/bash

set -ex

# ....
./committer
./vrelease
sleep 5

# ....
./committer
./vrelease -d
sleep 5

# ....
./committer
./vrelease -l 5
sleep 5

# ....
./committer
./vrelease -d -n
sleep 5

# ....
./committer
./vrelease -a committer
sleep 5

# ....
./committer
./vrelease -c -a committer
sleep 5

# ....
./committer
./vrelease -a committer -a vrelease -d -l 8
sleep 5

# ....
./committer
./vrelease -i -c -a committer
