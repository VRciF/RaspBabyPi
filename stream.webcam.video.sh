#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#ffmpeg -loglevel quiet -f video4linux2 -s 640x480 -framerate 10 -i /dev/video0 -y -vf "drawtext=text='%{localtime\:%T}': fontcolor=red@1.:fontsize=40:x=7:y=450" -f image2 -updatefirst 1 $DIR/stream.jpeg >/dev/null 2>&1

while [ 1 ]
do
    pushd $DIR >/dev/null
    rm -f ./video/*.jpg
    echo "" > video.log
    ffmpeg -loglevel error -f video4linux2 -s 640x480 -framerate 10 -i /dev/video0 -y -vf "drawtext=fontfile=/opt/vc/src/hello_pi/hello_font/Vera.ttf:text='%{localtime\:%T}': fontcolor=red@1.:fontsize=40:x=7:y=450" -f image2 -q:v 1 ./video/stream_%02d.jpg >video.log 2>&1
    popd >/dev/null
    sleep 5
done

