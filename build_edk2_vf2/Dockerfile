# SPDX-License-Identifier: 0BSD

# FROM debian:trixie-20231120@sha256:75f2c56ea6193ef5148af3c19d0321fcb0f1ffe9724dd6389df6bc50a46d116a
FROM ubuntu:jammy-20231004@sha256:c9cf959fd83770dfdefd8fb42cfef0761432af36a764c077aed54bbc5bb25368
MAINTAINER Heinrich Schuchardt <heinrich.schuchardt@canonical.com>
LABEL Description="Build EDK II for StarFive VisionFive 2"

ENV EDK2_RELEASE=REL_VF2_JUN2023
ENV EDK2_PLATFORM_RELEASE=REL_VF2_JUN2023

ENV WORKSPACE=/home/user
ENV GCC5_RISCV64_PREFIX=riscv64-linux-gnu-
ENV PACKAGES_PATH=/home/user/edk2:/home/user/edk2-platforms
ENV EDK_TOOLS_PATH=/home/user/edk2/BaseTools
ENV CONF_PATH=/home/user/edk2/Conf
ENV TOOL_CHAIN_TAG=GCC5
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
	u-boot-tools \
	uuid-dev

SHELL ["/bin/bash", "-c"]

# Create our user/group
RUN echo user ALL=NOPASSWD: ALL > /etc/sudoers.d/user
RUN useradd -m -U user
USER user:user
WORKDIR /home/user

# Clone EDK II
RUN git clone -v https://github.com/starfive-tech/edk2 edk2
RUN cd edk2 && git reset --hard $EDK2_RELEASE
RUN cd edk2 && git submodule update --init

# Clone EDK II Platforms
RUN git clone -v https://github.com/starfive-tech/edk2-platforms edk2-platforms
RUN cd edk2-platforms && git reset --hard $EDK2_PLATFORM_RELEASE
RUN cd edk2-platforms && git submodule update --init

# Build BaseTools
RUN cd edk2 && source edksetup.sh --reconfig && \
    make -C BaseTools -j $(nproc)

# Build EDK II
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a RISCV64 -b RELEASE -t GCC5 -n $(nproc) \
    -p edk2-platforms/Platform/StarFive/JH7110SeriesPkg/JH7110Board/JH7110.dsc

# Package as itb
COPY jh7110.its .
RUN mkimage -f jh7110.its jh7110.itb
