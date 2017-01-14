#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $DIR

while true; do

    pushd video >/dev/null
    find . -not -newermt '-5 seconds' -delete
    popd >/dev/null
    pushd audio >/dev/null
    find . -not -newermt '-5 seconds' -delete
    popd >/dev/null

    sleep 5;
done

popd

