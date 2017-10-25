#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#ffmpeg -f alsa -r 16000 -i plughw:CARD=C525,DEV=0 -acodec libmp3lame -ab 96k -f segment -segment_time 1 -updatefirst 1 -strftime 1 $DIR/stream.mp3

while [ 1 ]
do
    pushd $DIR >/dev/null
    rm -f ./audio/*.mp3
    echo "" > ./audio.log
#    ffmpeg -y -loglevel error -f alsa -ac 1 -i hw:1 -af "volume=1.5" -f segment -segment_time 1 -strftime 1 -segment_format mp3 ./audio/audio%01S.mp3 >audio.log 2>&1
#    ffmpeg -y -loglevel error -f alsa -ac 1 -i hw:1 -af "volume=5.0" -f segment -segment_time 1 -strftime 1 -segment_format mp3 ./audio/audio%01S.mp3 >audio.log 2>&1
#    ffmpeg -y -loglevel error -f alsa -ac 1 -i hw:1 -af "highpass=f=200, lowpass=f=3000, volume=5.0" -f segment -segment_time 1 -strftime 1 -segment_format mp3 ./audio/audio%01S.mp3 >audio.log 2>&1
    arecord -f cd -D plughw:1,0 | ffmpeg -i - -af "highpass=f=200, lowpass=f=3000, volume=5.0" -f segment -segment_time 1 -strftime 1 -segment_format mp3 ./audio/audio%01S.mp3 >audio.log 2>&1
    popd >/dev/null
    sleep 1
done

