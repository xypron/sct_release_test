SCT for AARCH64
===============

Build UEFI SCT for AARCH64
--------------------------

All Docker commands must be run as root.

.. code-block:: bash

    docker buildx build -t sct-aarch64:latest .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy sct-aarch64:latest
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/SctPackageAARCH64.tgz .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/QEMU_EFI.fd .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/QEMU_VARS.fd .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/Shell.efi .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'

Prepare SCT image
-----------------

Create an image file with an ESP partition with size 1 GiB and extract
SctPackageAARCH64.tgz to it.

Run SCT
-------

.. code-block:: bash

    qemu-system-aarch64 \
      -M virt -accel tcg -m 4096 -cpu max \
      -serial mon:stdio \
      -device virtio-gpu-pci \
      -device qemu-xhci \
      -device usb-kbd \
      -drive if=pflash,format=raw,unit=0,file=QEMU_EFI.fd,readonly=on \
      -drive if=pflash,format=raw,unit=1,file=QEMU_VARS.fd \
      -drive file=sct.img,format=raw,if=none,id=vda \
      -device virtio-blk-device,drive=vda,bootindex=1 \
      -device virtio-net-device,netdev=net0 \
      -netdev user,id=net0

In UEFI Shell

.. code-block:: batch

    FS0:
    cd SctPackageAARCH64
    InstallAARCH64.efi
    cd ../SCT
    sct -a
