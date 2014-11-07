#!/bin/bash

aptitude install libudns-dev libglib2.0-dev libssl-dev libcurl4-openssl-dev \
libreadline-dev libsqlite3-dev python-dev \
libtool automake autoconf build-essential \
subversion git-core \
flex bison \
pkg-config p0f

apt-get install unzip
apt-get install make
apt-get install git
apt-get install python-pip
apt-get install python-netaddr
apt-get install aptitude
apt-get install g++
apt-get install npm

mkdir /opt/dionaea


# liblcfg (todo)

git clone git://git.carnivore.it/liblcfg.git liblcfg
cd liblcfg/code || exit 1
autoreconf -vi
./configure --prefix=/opt/dionaea
make install
cd ..
cd ..


#libemu (todo)

git clone git://git.carnivore.it/libemu.git libemu
cd libemu || exit 1
autoreconf -vi
./configure --prefix=/opt/dionaea
make install
cd ..


#libnl (todo)

git clone git://github.com/tgraf/libnl.git
cd libnl || exit 1
autoreconf -vi
export LDFLAGS=-Wl,-rpath,/opt/dionaea/lib
./configure --prefix=/opt/dionaea
make
make install
cd ..


#libev (todo)

wget http://dist.schmorp.de/libev/Attic/libev-4.04.tar.gz
tar xfz libev-4.04.tar.gz
cd libev-4.04  || exit 1
./configure --prefix=/opt/dionaea
make install
cd ..




#Python3

wget http://www.python.org/ftp/python/3.2.3/Python-3.2.3.tgz
tar xfz Python-3.2.3.tgz
cd Python-3.2.3/ || exit 1
./configure --enable-shared --prefix=/opt/dionaea --with-computed-gotos \
      --enable-ipv6 LDFLAGS="-Wl,-rpath=/opt/dionaea/lib/ -L/usr/lib/x86_64-linux-gnu/"

make
make install
cd ..

#Cython (todo)

#We have to use cython >= 0.15 as previous releases do not support Python3.2 __hash__'s Py_Hash_type for x86.
wget http://cython.org/release/Cython-0.16.tar.gz
tar xfz Cython-0.16.tar.gz
cd Cython-0.16 || exit 1
/opt/dionaea/bin/python3 setup.py install
cd ..


#udns 
#udns does not use autotools to build.
wget http://www.corpit.ru/mjt/udns/old/udns_0.0.9.tar.gz
tar xfz udns_0.0.9.tar.gz
cd udns-0.0.9/ || exit 1
./configure
make shared
#There is no make install, so we copy the header to our include directory.
cp udns.h /opt/dionaea/include/
#and the lib to our library directory.
cp *.so* /opt/dionaea/lib/
cd /opt/dionaea/lib
ln -s libudns.so.0 libudns.so
cd -
cd ..


#libpcap 

wget http://www.tcpdump.org/release/libpcap-1.1.1.tar.gz
tar xfz libpcap-1.1.1.tar.gz
cd libpcap-1.1.1 || exit 1
./configure --prefix=/opt/dionaea
make
make install
cd ..


# FINAl !!!!

git clone git://git.carnivore.it/dionaea.git dionaea
cd dionaea || exit 1
autoreconf -vi
./configure --with-lcfg-include=/opt/dionaea/include/ \
      --with-lcfg-lib=/opt/dionaea/lib/ \
      --with-python=/opt/dionaea/bin/python3.2 \
      --with-cython-dir=/opt/dionaea/bin \
      --with-udns-include=/opt/dionaea/include/ \
      --with-udns-lib=/opt/dionaea/lib/ \
      --with-emu-include=/opt/dionaea/include/ \
      --with-emu-lib=/opt/dionaea/lib/ \
      --with-gc-include=/usr/include/gc \
      --with-ev-include=/opt/dionaea/include \
      --with-ev-lib=/opt/dionaea/lib \
      --with-nl-include=/opt/dionaea/include \
      --with-nl-lib=/opt/dionaea/lib/ \
      --with-curl-config=/usr/bin/ \
      --with-pcap-include=/opt/dionaea/include \
      --with-pcap-lib=/opt/dionaea/lib/ 
make
make install

#Fix some permissions
chown -R nobody:nogroup /opt/dionaea/var/dionaea
exit 0
