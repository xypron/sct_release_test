Build EDK II for SiFive HiFive Unleashed
========================================

To build EDK II for the SiFive HiFive Unleashed board run:

.. code-block:: bash

    docker build --progress tty -t edk2-u540:latest -f Dockerfile .
    docker container prune --force --filter 'label=TmpSctCopy'
    docker container create -l TmpSctCopy edk2-u540:latest
    docker container ls -a -q --filter 'label=TmpSctCopy' | \
      sed -e 's|\(\S*\).*|\1:/home/user/Build/FreedomU540HiFiveUnleashed/RELEASE_GCC5/FV/U540.fd .|' | \
      xargs docker cp
    docker container prune -f --filter 'label=TmpSctCopy'
