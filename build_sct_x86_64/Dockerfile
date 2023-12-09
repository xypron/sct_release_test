# SPDX-License-Identifier: 0BSD

FROM ubuntu:jammy@sha256:8eab65df33a6de2844c9aefd19efe8ddb87b7df5e9185a4ab73af936225685bb
MAINTAINER Heinrich Schuchardt <heinrich.schuchardt@canonical.com>
LABEL Description="Build SCT for amd64"

ENV EDK2_RELEASE=edk2-stable202311
ENV EDK2_TEST_RELEASE=81dfa8d53d4290366ae41e1f4c2ed6d6c5016c07

ENV WORKSPACE=/home/user
ENV GCC_X86_64_PREFIX=riscv64-linux-gnu-
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

COPY 0001-SctPkg-Fix-X64-build-errors-for-GCC-toolchain.patch \
     /home/user/0001-SctPkg-Fix-X64-build-errors-for-GCC-toolchain.patch
RUN git config --global user.email "user@localhost"
RUN git config --global user.name "User"
RUN cd edk2-test && git am --keep-cr ../00*.patch

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh X64 GCC RELEASE -n $(nproc) || true

RUN tar -czf SctPackageX64.tgz -C Build/UefiSct/RELEASE_GCC5/ \
    SctPackageX64

RUN tar -czf IhvSctPackageX64.tgz -C Build/IhvSct/RELEASE_GCC5/ \
    SctPackageX64

RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a X64 --buildtarget RELEASE \
    -p  ShellPkg/ShellPkg.dsc -t GCC -n $(nproc)
