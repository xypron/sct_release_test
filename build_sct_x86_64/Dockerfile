# SPDX-License-Identifier: 0BSD

# Ubuntu noble-amd64-20260509.1
FROM ubuntu:noble@sha256:023f8a753c22258c9fe2d0005a7d28258038da7d620e9f93e9ad78aa266f9f11 AS x86_64_base

LABEL org.opencontainers.image.description="Build SCT for X64"
LABEL org.opencontainers.image.source="https://github.com/xypron/sct_release_test.git"
LABEL org.opencontainers.image.authors="Heinrich Schuchardt <heinrich.schuchardt@canonical.com>"

ENV EDK2_RELEASE=edk2-stable202605
ENV EDK2_TEST_RELEASE=edk2-test-stable202608

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

RUN git config --global user.name 'user'
RUN git config --global user.email 'user@localhost'
RUN git config --global http.version HTTP/1.1

# Clone EDK II
RUN git clone -v \
    --branch $EDK2_RELEASE \
    --depth 1 \
    https://github.com/tianocore/edk2.git edk2
RUN cd edk2 && git submodule update --init

# Clone SCT
RUN git clone -v \
    --branch $EDK2_TEST_RELEASE \
    --depth 1 \
    --recurse-submodules \
    https://github.com/tianocore/edk2-test edk2-test
RUN cd edk2-test && git submodule update --init

# Build BaseTools
RUN cd edk2 && source edksetup.sh --reconfig && \
    make -C BaseTools -j $(nproc)

# Build SCT
RUN test -h SctPkg || ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
RUN cd edk2 && source edksetup.sh --reconfig && cd ../ && \
    SctPkg/build.sh X64 GCC RELEASE -n $(nproc)
RUN tar -czf SctPackageX64.tgz -C Build/UefiSct/RELEASE_GCC/ \
    SctPackageX64

# Build EDK II
RUN cd edk2 && source edksetup.sh BaseTools && cd ../ && \
    build -a X64 --buildtarget RELEASE \
    -t GCC -n $(nproc) \
    -DNETWORK_TLS_ENABLE \
    -DNETWORK_HTTP_ENABLE \
    -DNETWORK_HTTP_BOOT_ENABLE \
    -p OvmfPkg/OvmfPkgX64.dsc

RUN cp Build/OvmfX64/RELEASE_GCC/FV/OVMF_CODE.fd .
RUN cp Build/OvmfX64/RELEASE_GCC/FV/OVMF_VARS.fd .
RUN truncate -s 4194304 OVMF_CODE.fd
RUN truncate -s 4194304 OVMF_VARS.fd
RUN tar -czf OvmfPkgX64.tgz --transform 's|^|OvmfPkgX64/|' OVMF_*.fd
RUN rm *.fd
RUN cp Build/OvmfX64/RELEASE_GCC/X64/Shell.efi .
