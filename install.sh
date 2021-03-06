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

#http://www.redhenlab.org/home/the-cognitive-core-research-topics-in-red-hen/the-barnyard/hardware-encoding-with-the-raspberry-pi
#First activate the source repositories in /etc/apt/sources.list by adding this:
#deb-src http://mirror.ox.ac.uk/sites/archive.raspbian.org/archive/raspbian/ jessie main contrib non-free rpi
#deb-src http://archive.raspbian.org/raspbian/ jessie main contrib non-free rpi
#deb-src http://www.deb-multimedia.org jessie main non-free
#apt-get update
#apt-get install git autoconf automake build-essential checkinstall libass-dev libgpac-dev libmp3lame-dev \
#libopencore-amrnb-dev libopencore-amrwb-dev librtmp-dev libspeex-dev libtheora-dev libtool libvorbis-dev \
#pkg-config texi2html zlib1g-dev yasm dh-make fakeroot libfdk-aac-dev libx264-dev libjack0 libfftw3-dev libtool libtool-bin unzip
#cd ~/tmp
#git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
#cd fdk-aac
#autoreconf -fiv
#./configure --disable-shared
#make
#sudo checkinstall --pkgname=fdk-aac --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
#mv fdk-aac_*-git-1_armhf.deb ~/packages/


#echo "installing x264 codec"
#git clone --depth 1 git://git.videolan.org/x264
#cd x264
#./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
#time make -j 4
#sudo checkinstall --pkgname=x264 --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
cd ..

sudo apt-get install libmp3lame-dev

wget http://tipok.org.ua/downloads/media/aacplus/libaacplus/libaacplus-2.0.2.tar.gz
tar -xzf libaacplus-2.0.2.tar.gz
cd libaacplus-2.0.2
./autogen.sh --enable-shared --enable-static --with-parameter-expansion-string-replace-capable-shell=/bin/bash --host=arm-unknown-linux-gnueabi
make
checkinstall --pkgname=libaacplus --pkgversion="2.0.2" --backup=no --deldoc=yes --fstrans=no --default
cd ..

wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.25.tar.bz2
tar xjf alsa-lib-1.0.25.tar.bz2
cd alsa-lib-1.0.25/
./configure
make -j4
checkinstall --pkgname=alsa-lib --pkgversion="1.0.25" --backup=no --deldoc=yes --fstrans=no --default
cd ..

git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx/
./configure --enable-static --disable-examples --disable-unit-tests
make
checkinstall --pkgname=libvpx --pkgversion="$(date +%Y%m%d%H%M)" --backup=no --deldoc=yes --fstrans=no --default
cd ..

echo "installing ffmpeg"
git clone --depth=1 git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --enable-gpl --enable-libx264 --enable-nonfree --enable-libfreetype --enable-mmal --enable-omx --enable-omx-rpi --enable-libfdk-aac --enable-libass --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libspeex --enable-librtmp --enable-libtheora --enable-libvorbis --enable-version3 --enable-libvpx
time make -j4
checkinstall --pkgname=ffmpeg --pkgversion="$(date +%Y%m%d%H%M)" --backup=no --deldoc=yes --fstrans=no --default

popd

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Now add '$DIR/rc.local' to /etc/rc.local without the dashes and ure done"

