#!/bin/bash

set -ex

run_test() {
    ./committer
    docker run -e VRELEASE_AUTH_TOKEN="$TOKEN" vrelease $@
    sleep 5
}

run_test
run_test -d
run_test -l 5
run_test -d -n
run_test -a committer
run_test -c -a committer
run_test -a committer -a vrelease -d -l 8
run_test -i -c -a committer
