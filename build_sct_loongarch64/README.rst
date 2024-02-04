SCT for LoongArch64
===================

Build UEFI SCT for LoongArch64
------------------------------

All Docker commands must be run as root.

.. code-block:: bash

    docker buildx build -t sct-loongarch64:latest .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy sct-loongarch64:latest
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/SctPackageLOONGARCH64.tgz .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/QEMU_EFI.fd .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'

Prepare SCT image
-----------------

Create an image file with an ESP partition with size 1 GiB and extract
SctPackageLOONGARCH64.tgz to it.

Run SCT
-------

.. code-block:: bash

    qemu-system-loongarch64 \
    -machine virt -m 4G -cpu la464 -smp 1 \
    -nographic \
    -bios QEMU_EFI.fd -nographic \
    -drive file=sct.img,format=raw,if=virtio

In UEFI Shell

.. code-block:: batch

    FS0:
    cd SCT
    InstallLOONGARCH64.efi
    cd ..
    sct -a
