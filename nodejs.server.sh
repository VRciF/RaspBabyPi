#!/bin/bash

while [ 1 ]
do
    rm -f /var/www/html/audio/*.mp3
    rm -f /var/www/html/video/*.jpg
    node /var/www/html/server.js > /var/www/html/server.log 2>&1
    sleep 1
done

