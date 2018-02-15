FROM ubuntu:xenial

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="OpenMS port."
LABEL software.version="2.3.0"
LABEL version="0.1"

ENV software_version="2.3.0"

# Install dependencies
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install build-essential software-properties-common cmake make autoconf patch libtool automake git g++ qt4-default qt4-dev-tools libqtwebkit-dev libqt4-dbg libqt4-dev libqt4-opengl-dev libeigen3-dev libwildmagic-dev libxerces-c-dev libboost-all-dev libsvn-dev libgsl-dev libbz2-dev libzip-dev zlib1g-dev libsvm-dev libglpk-dev python-software-properties python-setuptools python-pip python-nose python-numpy python-wheel cython cython-dbg doxygen doxygen-dbg seqan-dev coinor-libcoinmp-dev coinor-libcoinutils-dev coinor-clp coinor-libcbc-dev coinor-libosi-dev && \
    pip install autowrap

# Clone OpenMS repo and create needed directories
RUN mkdir /usr/src/openms && \
    mkdir /usr/src/openms/contrib-build && \
    mkdir /usr/src/openms/openms-build && \
    cd /usr/src/openms && \
    git clone https://github.com/OpenMS/OpenMS && \
    cd /usr/src/openms/OpenMS && \
    git checkout tags/Release${software_version}

# Build remaining dependencies
WORKDIR /usr/src/openms
RUN git clone https://github.com/OpenMS/contrib
WORKDIR /usr/src/openms/contrib-build
RUN cmake -DBUILD_TYPE=LIST ../contrib && \
    cmake -DBUILD_TYPE=ALL ../contrib

# Build OpenMS
WORKDIR /usr/src/openms/openms-build
RUN cmake -DCMAKE_PREFIX_PATH="/usr/src/openms/contrib-build/;/usr/src/openms/contrib/;/usr/;/usr/local" -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off ../OpenMS && \
    make

# Build PyOpenMS
WORKDIR /usr/src/openms/openms-build
RUN cmake -DCMAKE_PREFIX_PATH="/usr/src/openms/contrib-build/;/usr/src/openms/contrib/;/usr/;/usr/local" -DBOOST_USE_STATIC=OFF -DHAS_XSERVER=Off -DPYOPENMS=ON ../OpenMS && make pyopenms
#RUN easy_install pyopenms
#RUN pip install -Iv pyopenms==${software_version}

# Clean up
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Set environment and user
ENV PATH /usr/src/openms/openms-build/bin/:$PATH
ENV LD_LIBRARY_PATH="/usr/src/openms/OpenMS/openms-build/lib:$LD_LIBRARY_PATH"

# Add testing to container
ADD runTest1.sh /usr/local/bin/runTest1.sh

