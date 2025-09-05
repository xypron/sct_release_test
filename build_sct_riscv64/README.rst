SCT for RISCV64
===============

Install build dependencies
--------------------------

.. code-block:: bash

    sudo apt-get install docker-buildx qemu-system-misc qemu-user-static


Build UEFI SCT for RISCV64
--------------------------

All Docker commands must be run as root.

.. code-block:: bash

    docker buildx build -f Dockerfile --build-arg ARCH=$(uname -i) \
      -t sct-riscv64:latest .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy sct-riscv64:latest
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/SctPackageRISCV64.tgz .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/RiscVVirtQemu.tgz .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/Shell.efi .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'

Prepare SCT image
-----------------

Create an image file with an ESP partition with size 1 GiB and extract
SctPackageRISCV64.tgz to it.

Run SCT
-------

.. code-block:: bash

    qemu-system-riscv64 \
      -M virt,acpi=off -accel tcg -m 4096 \
      -serial mon:stdio \
      -device virtio-gpu-pci \
      -device qemu-xhci \
      -device usb-kbd \
      -drive if=pflash,format=raw,unit=0,file=RISCV_VIRT_CODE.fd,readonly=on \
      -drive if=pflash,format=raw,unit=1,file=RISCV_VIRT_VARS.fd \
      -drive file=sct.img,format=raw,if=none,id=vda \
      -device virtio-blk-device,drive=vda,bootindex=1 \
      -device virtio-net-device,netdev=net0 \
      -netdev user,id=net0

In UEFI Shell

.. code-block:: batch

    FS0:
    cd SctPackageRISCV64
    InstallRISCV64.efi
    cd ../SCT
    sct -a
