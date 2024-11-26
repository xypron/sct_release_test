# SPDX-License-Identifier: 0BSD

ARG ARCH=x86_64

# Ubuntu noble-amd64-20240827.1
FROM ubuntu:noble@sha256:77d57fd89366f7d16615794a5b53e124d742404e20f035c22032233f1826bd6a as x86_64_base
# Ubuntu noble-arm64-20241015
FROM ubuntu:noble@sha256:1d79a71338df5bd07cc91b695451fe7ef932aae3b4e2f6b6d45885ef5082911e as aarch64_base
MAINTAINER Heinrich Schuchardt <heinrich.schuchardt@canonical.com>

FROM ${ARCH}_base

LABEL Description="Build SCT for aarch64"

ENV EDK2_RELEASE=edk2-stable202408
ENV EDK2_TEST_RELEASE=edk2-test-stable202406

ENV WORKSPACE=/home/user
ENV GCC_AARCH64_PREFIX=aarch64-linux-gnu-
ENV PACKAGES_PATH=/home/user/edk2:/home/user/edk2-test/uefi-sct
ENV EDK_TOOLS_PATH=/home/user/edk2/BaseTools
ENV CONF_PATH=/home/user/edk2/Conf
ENV TOOL_CHAIN_TAG=GCC
ENV CROSS_COMPILE_64=aarch64-linux-gnu-

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
	g++ \
	gcc \
	gcc-aarch64-linux-gnu \
	git \
	iasl \
	make \
	python3 \
	sudo \
	uuid-dev

SHELL ["/bin/bash", "-c"]

# Create our user/group
RUN echo user ALL=NOPASSWD: ALL > /etc/sudoers.d/user
RUN useradd -m -U user
USER user:user
WORKDIR /home/user

RUN git config --global user.name 'user'
RUN git config --global user.email 'user@localhost'

# Clone EDK II
RUN git clone -v https://github.com/tianocore/edk2 edk2
RUN cd edk2 && git reset --hard $EDK2_RELEASE
COPY 0001-UnitTestFrameworkPkg-Use-TianoCore-mirror-of-subhook.patch \
     /tmp/
RUN cd edk2 && git am --keep-cr \
     /tmp/0001-UnitTestFrameworkPkg-Use-TianoCore-mirror-of-subhook.patch
RUN cd edk2 && git submodule update --init

# Clone SCT
RUN git clone -v https://github.com/tianocore/edk2-test edk2-test
RUN cd edk2-test && git reset --hard $EDK2_TEST_RELEASE
RUN cd edk2-test && git submodule update --init

# Build BaseTools
RUN cd edk2 && source edksetup.sh --reconfig && \
    make -C BaseTools -j $(nproc)

# Build EDK II
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a AARCH64 --buildtarget RELEASE \
    -DNETWORK_TLS_ENABLE \
    -DNETWORK_HTTP_ENABLE \
    -DNETWORK_HTTP_BOOT_ENABLE \
    -p ArmVirtPkg/ArmVirtQemu.dsc -t GCC -n $(nproc)

RUN cp Build/ArmVirtQemu-AARCH64/RELEASE_GCC/FV/QEMU_EFI.fd .
RUN cp Build/ArmVirtQemu-AARCH64/RELEASE_GCC/FV/QEMU_VARS.fd .
RUN truncate -s 64M QEMU_EFI.fd
RUN truncate -s 64M QEMU_VARS.fd

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh AARCH64 GCC RELEASE

RUN tar -czf SctPackageAARCH64.tgz -C Build/UefiSct/RELEASE_GCC5/ \
    SctPackageAARCH64

# Get Shell.efi
RUN cp Build/ArmVirtQemu-AARCH64/RELEASE_GCC/AARCH64/Shell.efi .
