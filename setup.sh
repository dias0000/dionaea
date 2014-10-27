#!/bin/bash

aptitude update
aptitude -y safe-upgrade


# liblcfg (all)

cd liblcfg || exit 1
git clean
git pull
cd code
autoreconf -vi
./configure --prefix=/opt/dionaea
make install
cd ..
cd ..


#libemu (all)

cd libemu || exit 1
git clean
git pull
autoreconf -vi
./configure --prefix=/opt/dionaea
make install
cd ..


#libnl (linux && optional)

cd libnl || exit 1
git clean
git pull
autoreconf -vi
export LDFLAGS=-Wl,-rpath,/opt/dionaea/lib
./configure --prefix=/opt/dionaea
make
make install
cd ..


# FINALLY!!!!

cd dionaea || exit 1
git clean
git pull
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
