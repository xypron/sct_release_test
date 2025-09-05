# SPDX-License-Identifier: 0BSD

ARG ARCH=x86_64

# Ubuntu noble-amd64-20250805
FROM ubuntu:noble@sha256:3f83fb03282ef4e453bdf0060e0d83833bb3cf6e6f36f54d9b8517d311d78e03 AS x86_64_base
# Ubuntu noble-riscv64-20250805
FROM ubuntu:noble@sha256:d395fc5247d3375ba7d43d917e72fe4e0c24de38fb9f0af8f00b44270d14a31a AS riscv64_base

FROM ${ARCH}_base

LABEL org.opencontainers.image.description="Build SCT for riscv64"
LABEL org.opencontainers.image.source="https://github.com/xypron/sct_release_test.git"
LABEL org.opencontainers.image.authors="Heinrich Schuchardt <heinrich.schuchardt@canonical.com>"

ENV EDK2_RELEASE=edk2-stable202508
ENV EDK2_TEST_RELEASE=edk2-test-rc1_202509

ENV WORKSPACE=/home/user
ENV GCC_RISCV64_PREFIX=riscv64-linux-gnu-
ENV PACKAGES_PATH=/home/user/edk2:/home/user/edk2-test/uefi-sct
ENV EDK_TOOLS_PATH=/home/user/edk2/BaseTools
ENV CONF_PATH=/home/user/edk2/Conf
ENV TOOL_CHAIN_TAG=GCC
ENV CROSS_COMPILE_64=riscv64-linux-gnu-

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
	g++ \
	gcc \
	gcc-riscv64-linux-gnu \
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

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh RISCV64 GCC RELEASE

RUN tar -czf SctPackageRISCV64.tgz -C Build/UefiSct/RELEASE_GCC5/ \
    SctPackageRISCV64

# Build EDK II
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a RISCV64 --buildtarget RELEASE \
    -DNETWORK_TLS_ENABLE \
    -DNETWORK_HTTP_ENABLE \
    -DNETWORK_HTTP_BOOT_ENABLE \
    -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t GCC -n $(nproc)

RUN cp Build/RiscVVirtQemu/RELEASE_GCC/FV/RISCV_VIRT_CODE.fd .
RUN cp Build/RiscVVirtQemu/RELEASE_GCC/FV/RISCV_VIRT_VARS.fd .
RUN truncate -s 33554432 RISCV_VIRT_CODE.fd
RUN truncate -s 33554432 RISCV_VIRT_VARS.fd
RUN tar -czf RiscVVirtQemu.tgz --transform 's|^|RiscVVirtQemu/|' RISCV_VIRT_*.fd
RUN rm *.fd
