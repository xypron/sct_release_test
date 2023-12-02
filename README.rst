Test UEFI SCT
=============

Build UEFI SCT for RISC-V
-------------------------

.. code-block:: bash

    docker build --progress tty -t edk2-test:latest -f build_sct/Dockerfile .
    docker run -ti edk2-test:latest &
    docker container ls -a | \
      grep edk2-test:latest | \
      sed -e 's|\(\S*\).*|\1:/home/user/SctPackageRISCV64.tgz .|' | \
      xargs docker cp
    docker container ls -a | \
      grep edk2-test:latest | \
      sed -e 's|\(\S*\).*|\1:/home/user/RiscVVirtQemu.tgz .|' | \
      xargs docker cp
    kill -SIGKILL $!

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
