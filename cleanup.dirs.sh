#!/bin/bash

while true; do

    pushd /var/www/html/video
    find . -not -newermt '-5 seconds' -delete
    popd
    pushd /var/www/html/audio
    find . -not -newermt '-5 seconds' -delete
    popd

    sleep 5;
done

