# SPDX-License-Identifier: 0BSD

FROM ubuntu:jammy@sha256:bcc511d82482900604524a8e8d64bf4c53b2461868dac55f4d04d660e61983cb
MAINTAINER Heinrich Schuchardt <heinrich.schuchardt@canonical.com>
LABEL Description="Build SCT for loongarch64"

ENV EDK2_RELEASE=edk2-stable202402
ENV EDK2_TEST_RELEASE=edk2-test-rc2_202405
ENV EDK2_PLATFORMS_RELEASE=8b9a0ec76bdc12239391ab7e08055906c0eac731

ENV WORKSPACE=/home/user
ENV GCC_LOONGARCH64_PREFIX=loongarch64-linux-gnu-
ENV PACKAGES_PATH=/home/user/edk2:/home/user/edk2-test/uefi-sct:/home/user/edk2-platforms
ENV EDK_TOOLS_PATH=/home/user/edk2/BaseTools
ENV CONF_PATH=/home/user/edk2/Conf
ENV TOOL_CHAIN_TAG=GCC
ENV CROSS_COMPILE_64=/opt/gcc/bin/loongarch64-linux-
ENV GCC_LOONGARCH64_PREFIX=/opt/gcc/bin/loongarch64-linux-

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
	g++ \
	gcc \
	git \
	iasl \
	make \
	python3 \
	sudo \
	uuid-dev \
	wget

SHELL ["/bin/bash", "-c"]

# Download gcc
WORKDIR /tmp
RUN wget https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/13.2.0/x86_64-gcc-13.2.0-nolibc-loongarch64-linux.tar.gz
RUN sha256sum x86_64-gcc-13.2.0-nolibc-loongarch64-linux.tar.gz | \
    grep ce1ee73f78d20c30f8ed94b48d13814bf185eb7f668f0aaef89baec33eeed2a0
RUN tar -xzf x86_64-gcc-13.2.0-nolibc-loongarch64-linux.tar.gz \
    --transform 's|gcc-13.2.0-nolibc/loongarch64-linux/|opt/gcc/|' -C /
RUN rm x86_64-gcc-13.2.0-nolibc-loongarch64-linux.tar.gz

# Create our user/group
RUN echo user ALL=NOPASSWD: ALL > /etc/sudoers.d/user
RUN useradd -m -U user
USER user:user
WORKDIR /home/user

# Clone EDK II
RUN git clone -v https://github.com/tianocore/edk2 edk2
RUN cd edk2 && git reset --hard $EDK2_RELEASE
RUN cd edk2 && git submodule update --init

# Clone SCT
RUN git clone -v https://github.com/tianocore/edk2-test edk2-test
RUN cd edk2-test && git reset --hard $EDK2_TEST_RELEASE
RUN cd edk2-test && git submodule update --init

# Clone EDK II Platforms
RUN git clone -v https://github.com/tianocore/edk2-platforms.git
RUN cd edk2-platforms && git reset --hard $EDK2_PLATFORMS_RELEASE
RUN cd edk2-platforms && git submodule update --init

# Build BaseTools
RUN cd edk2 && source edksetup.sh --reconfig && \
    make -C BaseTools -j $(nproc)

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh LOONGARCH64 GCC5 RELEASE

RUN tar -czf SctPackageLOONGARCH64.tgz -C Build/UefiSct/RELEASE_GCC5/ \
    SctPackageLOONGARCH64

# Build EDK II
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    build --buildtarget=RELEASE --tagname=GCC --arch=LOONGARCH64 \
    --platform=Platform/Loongson/LoongArchQemuPkg/Loongson.dsc

RUN cp Build/LoongArchQemu/RELEASE_GCC/FV/QEMU_VARS.fd .
RUN cp Build/LoongArchQemu/RELEASE_GCC/FV/QEMU_EFI.fd .
