SCT for X86_64
===============

Build UEFI SCT for X86_64
--------------------------

All Docker commands must be run as root.

.. code-block:: bash

    docker buildx build -t sct-x86_64:latest .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy sct-x86_64:latest
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/SctPackageX64.tgz .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/Shell.efi .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'

Prepare SCT image
-----------------

Create an image file with an ESP partition with size 1 GiB and extract
SctPackageX64.tgz to it.

Run SCT
-------

.. code-block:: bash

    qemu-system-x86_64 \
      -M q35,smm=on,accel=kvm -smp 2 -m 4G \
      -serial mon:stdio \
      -device qemu-xhci \
      -device usb-kbd \
      -device virtio-gpu-pci \
      -global driver=cfi.pflash01,property=secure,value=on \
      -drive if=pflash,format=raw,unit=0,file=/usr/share/OVMF/OVMF_CODE_4M.fd,readonly=on \
      -drive if=pflash,format=raw,unit=1,file=OVMF_VARS_4M.fd \
      -drive file=amd64.img,format=raw,if=none,id=vda \
      -device virtio-blk-pci,drive=vda,bootindex=1 \
      -device virtio-net-pci,netdev=eth1,romfile="" \
      -netdev user,id=eth1

In UEFI Shell

.. code-block:: batch

    FS0:
    cd SctPackageX64
    InstallX64.efi
    cd ../SCT
    sct -a
