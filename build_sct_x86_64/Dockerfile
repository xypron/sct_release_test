# SPDX-License-Identifier: 0BSD

# Ubuntu noble-amd64-20240827.1
FROM ubuntu:noble@sha256:77d57fd89366f7d16615794a5b53e124d742404e20f035c22032233f1826bd6a
MAINTAINER Heinrich Schuchardt <heinrich.schuchardt@canonical.com>
LABEL Description="Build SCT for amd64"

ENV EDK2_RELEASE=edk2-stable202402
ENV EDK2_TEST_RELEASE=edk2-test-stable202406

ENV WORKSPACE=/home/user
ENV PACKAGES_PATH=/home/user/edk2:/home/user/edk2-test/uefi-sct
ENV EDK_TOOLS_PATH=/home/user/edk2/BaseTools
ENV CONF_PATH=/home/user/edk2/Conf
ENV TOOL_CHAIN_TAG=GCC

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
	g++ \
	gcc \
	git \
	iasl \
	make \
	nasm \
	python3 \
	sudo \
	uuid-dev

SHELL ["/bin/bash", "-c"]

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

# Build BaseTools
RUN cd edk2 && source edksetup.sh --reconfig && \
    make -C BaseTools -j $(nproc)

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh X64 GCC RELEASE -n $(nproc)

RUN tar -czf SctPackageX64.tgz -C Build/UefiSct/RELEASE_GCC5/ \
    SctPackageX64

# Build EFI Shell
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a X64 --buildtarget RELEASE \
    -p  ShellPkg/ShellPkg.dsc -t GCC -n $(nproc)
