# SPDX-License-Identifier: 0BSD

ARG ARCH=x86_64

# Ubuntu noble-amd64-20260509.1
FROM ubuntu:noble@sha256:023f8a753c22258c9fe2d0005a7d28258038da7d620e9f93e9ad78aa266f9f11 AS x86_64_base
# Ubuntu noble-arm64-20260705
FROM ubuntu:noble@sha256:1e0a86e57d247923571b75e0aaf48a1449cf8c543d51fb3e07a4a7d7bfa79316 AS aarch64_base

FROM ${ARCH}_base

LABEL org.opencontainers.image.description="Build SCT for aarchv64"
LABEL org.opencontainers.image.source="https://github.com/xypron/sct_release_test.git"
LABEL org.opencontainers.image.authors="Heinrich Schuchardt <heinrich.schuchardt@canonical.com>"

ENV EDK2_RELEASE=edk2-stable202605
ENV EDK2_TEST_RELEASE=edk2-test-stable202608

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

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh AARCH64 GCC RELEASE

# Copy EDK II flash images
RUN cp Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV/QEMU_EFI.fd .
RUN cp Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV/QEMU_VARS.fd .
RUN truncate -s 64M QEMU_EFI.fd
RUN truncate -s 64M QEMU_VARS.fd
RUN tar -czf Aarch64VirtQemu.tgz --transform 's|^|Aarch64VirtQemu/|' QEMU_*.fd
RUN rm *.fd

# Create SCT archive
RUN tar -czf SctPackageAARCH64.tgz -C Build/UefiSct/RELEASE_GCC/ \
    SctPackageAARCH64

# Get Shell.efi
RUN cp Build/ArmVirtQemu-AArch64/RELEASE_GCC/AARCH64/Shell.efi .
