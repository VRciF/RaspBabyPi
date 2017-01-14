#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [ 1 ]
do
    pushd $DIR >/dev/null
    rm -f ./audio/*.mp3
    rm -f ./video/*.jpg
    echo "starting node"
    node server.js >server.log 2>&1
    popd >/dev/null
    sleep 1
done

