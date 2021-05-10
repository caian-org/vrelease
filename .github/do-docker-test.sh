#!/bin/bash

set -ex

# ....
./committer
docker run vrelease
./vrelease
sleep 5

# ....
./committer
docker run vrelease -d
sleep 5

# ....
./committer
docker run vrelease -l 5
sleep 5

# ....
./committer
docker run vrelease -d -n
sleep 5

# ....
./committer
docker run vrelease -a committer
sleep 5

# ....
./committer
docker run vrelease -c -a committer
sleep 5

# ....
./committer
docker run vrelease -a committer -a vrelease -d -l 8
sleep 5

# ....
./committer
docker run vrelease -i -c -a committer
