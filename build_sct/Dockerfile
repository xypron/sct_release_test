# SPDX-License-Identifier: 0BSD

# FROM debian:trixie-20231120@sha256:75f2c56ea6193ef5148af3c19d0321fcb0f1ffe9724dd6389df6bc50a46d116a
FROM ubuntu:jammy-20231004@sha256:c9cf959fd83770dfdefd8fb42cfef0761432af36a764c077aed54bbc5bb25368
MAINTAINER Heinrich Schuchardt <heinrich.schuchardt@canonical.com>
LABEL Description="Build SCT for riscv64"

ENV EDK2_RELEASE=edk2-stable202311
ENV EDK2_TEST_RELEASE=81dfa8d53d4290366ae41e1f4c2ed6d6c5016c07

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
    SctPkg/build.sh RISCV64 GCC RELEASE || true

RUN tar -czf SctPackageRISCV64.tgz -C Build/UefiSct/RELEASE_GCC5/ \
    SctPackageRISCV64

# Build EDK II
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a RISCV64 --buildtarget RELEASE \
    -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t GCC -n $(nproc)

RUN cp Build/RiscVVirtQemu/RELEASE_GCC/FV/RISCV_VIRT_CODE.fd .
RUN cp Build/RiscVVirtQemu/RELEASE_GCC/FV/RISCV_VIRT_VARS.fd .
RUN truncate -s 33554432 RISCV_VIRT_CODE.fd
RUN truncate -s 33554432 RISCV_VIRT_VARS.fd
RUN tar -czf RiscVVirtQemu.tgz --transform 's|^|RiscVVirtQemu/|' RISCV_VIRT_*.fd
RUN rm *.fd
