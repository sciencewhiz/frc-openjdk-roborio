FROM ubuntu:18.04

RUN apt-get update && apt-get install -y tzdata && apt-get install -y \
    autoconf \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    file \
    g++ --no-install-recommends \
    gcc \
    gdb \
    java-common \
    libc6-dev \
    libcups2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libisl15 \
    libpython2.7 \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxtst-dev \
    libxt-dev \
    make \
    mercurial \
    unzip \
    wget \
    zip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN hg clone http://hg.openjdk.java.net/jdk/jdk11 jdk11

# Install toolchain
COPY --from=wpilib/roborio-toolchain:2018-future-18.04 /packages/*.deb /packages/
RUN dpkg -i /packages/*.deb && rm -rf /packages

# Install OpenJDK 10 (required to build OpenJDK 11)
WORKDIR /usr/lib/jvm
RUN curl -SL https://download.java.net/java/GA/jdk10/10.0.2/19aef61b38124481863b1413dce1855f/13/openjdk-10.0.2_linux-x64_bin.tar.gz | tar xzf -
COPY jdk-10.jinfo .jdk-10.0.2.jinfo
RUN bash -c "grep /usr/lib/jvm .jdk-10.0.2.jinfo | awk '{ print \"update-alternatives --install /usr/bin/\" \$2 \" \" \$2 \" \" \$3 \" 2\"; }' | bash " \
  && update-java-alternatives -s jdk-10.0.2

# Add ARM files for x11 (not RoboRIO, but doesn't have to be)
ADD arm-x11-files.tar.xz /usr/arm-frc2018-linux-gnueabi/

WORKDIR /tmp

RUN wget http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/alsa-lib-dev_1.1.0-r0.5_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/alsa-lib_1.1.0-r0.5_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/cups-dev_2.1.3-r0.5_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/libasound2_1.1.0-r0.5_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/libfontconfig-dev_2.11.94-r0.38_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/libfontconfig1_2.11.94-r0.38_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/libfreetype-dev_2.6.3-r0.36_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/libfreetype6_2.6.3-r0.36_cortexa9-vfpv3.ipk \
    http://download.ni.com/ni-linux-rt/feeds/2017/arm/ipk/cortexa9-vfpv3/libz1_1.2.8-r0.329_cortexa9-vfpv3.ipk \
  && for f in *.ipk; do \
    ar p $f data.tar.gz | sh -c 'cd /usr/arm-frc2018-linux-gnueabi && tar xzf -'; \
  done \
  && rm *.ipk

WORKDIR /build/jdk11

