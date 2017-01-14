#!/bin/bash

#ffmpeg -f alsa -r 16000 -i plughw:CARD=C525,DEV=0 -acodec libmp3lame -ab 96k -f segment -segment_time 1 -updatefirst 1 -strftime 1 /var/www/html/stream.mp3

while [ 1 ]
do
    rm -f /var/www/html/audio/*.mp3
    echo "" > /var/www/html/audio.log
#    ffmpeg -y -loglevel error -f alsa -ac 1 -i hw:1 -af "volume=1.5" -f segment -segment_time 1 -strftime 1 -segment_format mp3 /var/www/html/audio/audio%01S.mp3 > /var/www/html/audio.log 2>&1
#    ffmpeg -y -loglevel error -f alsa -ac 1 -i hw:1 -af "volume=5.0" -f segment -segment_time 1 -strftime 1 -segment_format mp3 /var/www/html/audio/audio%01S.mp3 > /var/www/html/audio.log 2>&1
    ffmpeg -y -loglevel error -f alsa -ac 1 -i hw:1 -af "highpass=f=200, lowpass=f=3000, volume=5.0" -f segment -segment_time 1 -strftime 1 -segment_format mp3 /var/www/html/audio/audio%01S.mp3 > /var/www/html/audio.log 2>&1

    sleep 1
done

