Build EDK II for StarFive VisionFive 2
======================================

The vendor provides this wiki page:
https://github.com/starfive-tech/edk2/wiki/Quick-Start-Guide

To build EDK II for the StarFive VisionFive 2 board run:

.. code-block:: bash

    docker build --progress tty -t edk2-vf2:latest -f Dockerfile .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy edk2-vf2:latest
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/Build/JH7110/RELEASE_GCC5/FV/JH7110.fd .|' | \
      xargs docker cp
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/jh7110.itb .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'

File JH7110.fd requires a patched U-Boot SPL.

File jh7110.itb can be used with the upstream U-Boot SPL.
