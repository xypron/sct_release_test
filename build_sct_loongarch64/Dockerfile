# SPDX-License-Identifier: 0BSD

# Ubuntu resolute-amd64-20260811.1
FROM ubuntu:resolute@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

LABEL Description="Build SCT for loongarch64"
LABEL org.opencontainers.image.source="https://github.com/xypron/sct_release_test.git"
LABEL org.opencontainers.image.authors="Heinrich Schuchardt <heinrich.schuchardt@canonical.com>"

ENV EDK2_RELEASE=edk2-stable202605
ENV EDK2_TEST_RELEASE=edk2-test-stable202608

ENV WORKSPACE=/home/user
ENV GCC_LOONGARCH64_PREFIX=loongarch64-linux-gnu-
ENV PACKAGES_PATH=/home/user/edk2:/home/user/edk2-test/uefi-sct
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
RUN wget https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/16.2.0/x86_64-gcc-16.2.0-nolibc-loongarch64-linux.tar.gz
RUN sha256sum x86_64-gcc-16.2.0-nolibc-loongarch64-linux.tar.gz | \
    grep 12b3fe8ceeac364d1889bc98a9925850a57880819812a985f5ac33779e313c30
RUN tar -xzf x86_64-gcc-16.2.0-nolibc-loongarch64-linux.tar.gz \
    --transform 's|gcc-16.2.0-nolibc/loongarch64-linux/|opt/gcc/|' -C /
RUN rm x86_64-gcc-16.2.0-nolibc-loongarch64-linux.tar.gz

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

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh LOONGARCH64 GCC RELEASE

RUN tar -czf SctPackageLOONGARCH64.tgz -C Build/UefiSct/RELEASE_GCC/ \
    SctPackageLOONGARCH64

# Build EDK II
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a LOONGARCH64 --buildtarget RELEASE \
    -DNETWORK_IP6_ENABLE \
    -DNETWORK_TLS_ENABLE \
    -DNETWORK_HTTP_ENABLE \
    -DNETWORK_HTTP_BOOT_ENABLE \
    -p OvmfPkg/LoongArchVirt/LoongArchVirtQemu.dsc -t GCC -n $(nproc)

RUN cp Build/LoongArchVirtQemu/RELEASE_GCC/FV/QEMU_EFI.fd .
RUN cp Build/LoongArchVirtQemu/RELEASE_GCC/FV/QEMU_VARS.fd .
RUN truncate -s 16777216 QEMU_EFI.fd
RUN truncate -s 16777216 QEMU_VARS.fd
RUN tar -czf LoongArchVirtQemu.tgz --transform 's|^|LoongArchVirtQemu/|' QEMU_*.fd
RUN rm *.fd
RUN cp Build/LoongArchVirtQemu/RELEASE_GCC/LOONGARCH64/Shell.efi .
