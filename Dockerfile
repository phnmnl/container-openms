FROM ubuntu:xenial

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="OpenMS port."
LABEL software.version="2.3.0"
LABEL version="0.1"

ENV software_version="2.3.0"

# Install dependencies
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install build-essential software-properties-common cmake make autoconf patch libtool automake git g++ qt4-default qt4-dev-tools libqtwebkit-dev libqt4-dbg libqt4-dev libqt4-opengl-dev qt4-dev-tools qt4-default qt4-qtconfig qt4-qmake libqt4-dev libqt4-opengl-dev libqt4-svg libqtwebkit-dev libeigen3-dev libwildmagic-dev libxerces-c-dev libboost-all-dev libsvn-dev libgsl-dev libbz2-dev libzip-dev zlib1g-dev libsvm-dev libglpk-dev python-software-properties python-setuptools python-pip python-nose python-numpy python-wheel cython cython-dbg doxygen doxygen-dbg seqan-dev libcoin80-dev coinor-libcoinmp-dev coinor-libcoinutils-dev coinor-clp coinor-cbc coinor-csdp coinor-libcbc-dev coinor-libcbc3 coinor-libcgl-dev coinor-libcgl1 coinor-libclp-dev coinor-libdylp-dev coinor-libflopc++-dev coinor-libipopt-dev coinor-libosi-dev coinor-libsymphony-dev coinor-libvol-dev texlive-latex-base

# Clone OpenMS repo
RUN mkdir /usr/src/openms && \
    mkdir /usr/src/openms/contrib-build && \
    mkdir /usr/src/openms/openms-build && \
    cd /usr/src/openms && \
    git clone https://github.com/OpenMS/OpenMS && \
    cd /usr/src/openms/OpenMS && \
    git checkout tags/Release${software_version} && \
    cd /usr/src/openms/ && \
    git clone https://github.com/OpenMS/contrib && \
    cd /usr/src/openms/contrib && \
    git checkout tags/Release${software_version} && \
    rm -rf /usr/src/openms/contrib/.git/

# Build OpenMS contrib
WORKDIR /usr/src/openms/contrib-build
RUN cmake -DBUILD_TYPE=SEQAN ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=WILDMAGIC ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=EIGEN ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=COINOR ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=SQLITE ../contrib && rm -rf archives src

# Build OpenMS
WORKDIR /usr/src/openms/openms-build
RUN cmake -DOPENMS_CONTRIB_LIBS="/usr/src/openms/contrib-build" -DCMAKE_PREFIX_PATH="/usr/src/openms/contrib-build/;/usr/src/openms/contrib/;/usr;/usr/local" -DBOOST_USE_STATIC=OFF ../OpenMS && \
    make OpenMS

# Build PyOpenMS
RUN pip install -U pip && \
    pip install -U nose && \
    pip install -U setuptools && \
    pip install -U Cython && \
    pip install -U autowrap
WORKDIR /usr/src/openms/openms-build
RUN cmake -DOPENMS_CONTRIB_LIBS="/usr/src/openms/contrib-build" -DCMAKE_PREFIX_PATH="/usr/src/openms/contrib-build/;/usr/src/openms/contrib/;/usr;/usr/local" -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off -DPYOPENMS=On ../OpenMS && \
    make pyopenms
WORKDIR /usr/src/openms/openms-build/pyOpenMS
RUN python setup.py install

# Clean up
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Set environment and user
ENV PATH="/usr/src/openms/openms-build/bin/:$PATH"
ENV LD_LIBRARY_PATH="/usr/src/openms/OpenMS/openms-build/lib:$LD_LIBRARY_PATH"

# Add testing to container
ADD runTest1.sh /usr/local/bin/runTest1.sh

