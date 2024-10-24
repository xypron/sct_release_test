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

Build UEFI SCT
--------------

Please, navigate to the relevant build_sct directory for the archtitecture
you are interested in and follow the respective README.rst.

* build_sct_arm
* build_sct_ia32
* build_sct_x86_64
* build_sct_loongarch64
* build_sct_riscv64
* build_sct_aarch64

Device specific EDK II can be built in directories

* build_edk2_vf2

All Docker commands must be run as root.

Run the SCT
-----------

Follow the respective README.rst in the subdirectories.
