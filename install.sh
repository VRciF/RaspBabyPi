#!/bin/bash

#echo "updating the system"
#apt-get update
#apt-get upgrade

echo "installing sox"
sudo apt-get install -y sox

echo "installing node"
pushd /opt
wget https://nodejs.org/dist/v7.4.0/node-v7.4.0-linux-armv6l.tar.gz
sudo tar -xzf node-v7.4.0-linux-armv6l.tar.gz
sudo mv node-v7.4.0-linux-armv6l nodejs
sudo rm node-v7.4.0-linux-armv6l.tar.gz
sudo ln -s /opt/nodejs/bin/node /usr/bin/node
sudo ln -s /opt/nodejs/bin/npm /usr/bin/npm
popd

pushd $DIR
echo "installing required node modules"
npm install
popd

pushd /tmp

#echo "installing x264 codec"
#git clone --depth 1 git://git.videolan.org/x264
#cd x264
#./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
#time make -j 4
#sudo make install

echo "installing ffmpeg"
git clone --depth=1 git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
#./configure --arch=armel --target-os=linux --enable-gpl --enable-libx264 --enable-nonfree --enable-libfreetype
./configure --arch=armel --target-os=linux --enable-gpl --enable-nonfree --enable-libfreetype
time make -j4
sudo make install

popd

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Now add '$DIR/rc.local' to /etc/rc.local without the dashes and ure done"

