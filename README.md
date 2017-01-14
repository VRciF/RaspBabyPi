# RaspBabyPi
Baby monitor based on nodejs and raspberry pi

The goal for this project is to have an easy to use babyphone including video and audio. With "easy to use" it is meant, that it doesnt matter when you connect a webcam or microphone. Once a webcam or microphone is connected it will be used automatically until you disconnect. So for example it doesnt matter if you turn on the raspberry pi and later on connect the webcam or have it connected at boot time. The same holds for the microphone. In both cases /dev/vide0 or hw:1 are used hardcoded and checked in an endless loop to start streaming once any of the devices is connected to the raspberry pi (or any other linux box).

The webcam resolution is fixed to 640x480 and audio bitrate and quality is not altered.

So the source of the video/audio stream is a webcam/microphone whereas the destination is a webbrowser. The webcam is used to capture around 10 frames per second as jpgs which are sent to a browser using websocket.
The microphone creates 1 second mp3 chunks which are sent to the browser using websocket too and decoded using the web audio api.

So basically every browser should be able to get the video stream, whereas for the audio stream a browser supporting web audio api is needed.

Since audio is a bit tricky to not get clicking noises in between the mp3 chunks, an expermiental noise reducer is implemented which automatically detects background noise and removes it from the mp3 chunks.

# Installation
apt-get update
apt-get upgrade
apt-get install -y sox

pushd /tmp

git clone --depth 1 git://git.videolan.org/x264
cd x264
./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
make -j 4
sudo make install
 
# build and make ffmpeg
git clone --depth=1 git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --arch=armel --target-os=linux --enable-gpl --enable-libx264 --enable-nonfree --enable-libfreetype
make -j4
sudo make install

popd
