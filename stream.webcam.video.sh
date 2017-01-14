#!/bin/bash

#ffmpeg -loglevel quiet -f video4linux2 -s 640x480 -framerate 10 -i /dev/video0 -y -vf "drawtext=text='%{localtime\:%T}': fontcolor=red@1.:fontsize=40:x=7:y=450" -f image2 -updatefirst 1 /var/www/html/stream.jpeg >/dev/null 2>&1

while [ 1 ]
do
    rm -f /var/www/html/video/*.jpg
    echo "" > /var/www/html/video.log
    ffmpeg -loglevel error -f video4linux2 -s 640x480 -framerate 10 -i /dev/video0 -y -vf "drawtext=text='%{localtime\:%T}': fontcolor=red@1.:fontsize=40:x=7:y=450" -f image2 -q:v 1 /var/www/html/video/stream_%02d.jpg > /var/www/html/video.log 2>&1
    sleep 1
done

