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
    kill -SIGKILL $!
