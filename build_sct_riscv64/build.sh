#!/bin/bash

set -e

EDK2_RELEASE=edk2-stable202508
EDK2_TEST_RELEASE=edk2-test-stable202509

rm -rf build/
mkdir build

cd build/

WORKSPACE=$(pwd)
GCC_RISCV64_PREFIX=riscv64-linux-gnu-
PACKAGES_PATH=$(pwd)/edk2:$(pwd)/edk2-test/uefi-sct
EDK_TOOLS_PATH=$(pwd)/edk2/BaseTools
CONF_PATH=$(pwd)/edk2/Conf
TOOL_CHAIN_TAG=GCC

# Clone EDK II
git clone -v https://github.com/tianocore/edk2 edk2
cd edk2
git reset --hard $EDK2_RELEASE
git submodule update --init

# Build BaseTools
source edksetup.sh --reconfig
make -C BaseTools -j$(nproc)
cd ..

# Clone SCT
git clone -v https://github.com/tianocore/edk2-test edk2-test
cd edk2-test
git reset --hard $EDK2_TEST_RELEASE
cd ..

# Build SCT
ln -s edk2-test/uefi-sct/SctPkg/ SctPkg
CROSS_COMPILE_64=riscv64-linux-gnu- SctPkg/build.sh RISCV64 GCC RELEASE

# Create archive with SCT release files
tar -czf ../SctPackageRISCV64.tgz -C Build/UefiSct/RELEASE_GCC5/ SctPackageRISCV64
