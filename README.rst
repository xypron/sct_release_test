Test UEFI SCT
=============

Install build dependencies
--------------------------

To install Docker on Ubuntu:

.. code-block:: bash

    sudo apt-get update
    sudo apt-get install docker.io

In current Ubuntu versions Docker buildx is available as a replacement for the
legacy build client.

.. code-block:: bash

    sudo apt-get install docker-buildx

Build UEFI SCT for RISC-V
-------------------------

All Docker commands must be run as root.

.. code-block:: bash

    docker build --progress tty -t sct-riscv64:latest \
      -f build_sct_riscv64/Dockerfile .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy sct-riscv64:latest
    docker container ls -a --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/SctPackageRISCV64.tgz .|' | \
      xargs docker cp
    docker container ls -a --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/RiscVVirtQemu.tgz .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'

Run SCT
-------

Prepare the disk image
''''''''''''''''''''''

* Create a disk image with a 1 GiB ESP.
* Copy the content of SctPackageRISCV64.tgz to the disk

Run SCT
'''''''

* In the EFI shell execute SctPackageRISCV64/InstallRISCV64.efi to install the
  SCT.
* Execute SCT/SCT.efi
* Generate a result file with SCT.efi -g <filename>

Run with QEMU
'''''''''''''

QEMU >= 8.1 is needed.

.. code-block:: bash

    /usr/bin/qemu-system-riscv64 \
      -M virt,acpi=off -accel tcg -m 4096 \
      -serial mon:stdio \
      -device virtio-gpu-pci \
      -device qemu-xhci \
      -device usb-kbd \
      -drive if=pflash,format=raw,unit=0,file=RISCV_VIRT_CODE.fd,readonly=on \
      -drive if=pflash,format=raw,unit=1,file=RISCV_VIRT_VARS.fd \
      -drive file=sct.img,format=raw,if=virtio \
      -device virtio-net-device,netdev=net0 \
      -netdev user,id=net0
