This directory contains the result files from running the SCT on QEMU with

* QEMU 8.2-rc2
* EDK II, version edk2-stable202311
* SCT commit 81dfa8d53d4290366ae41e1f4c2ed6d6c5016c07

A failure in the emulator occured twice. Cf.
https://gitlab.com/qemu-project/qemu/-/issues/2014

The SCT continued after restarting the emulation.


------------------------------------------------------------
UEFI 2.6
Revision 0x00010000
Test Entry Point GUID: B18E7416-3D1D-4595-BD28-E316EEB0A592
------------------------------------------------------------
Logfile: "\Sct\Log\ConsoleSupportTest\SimplePointerProtocolTest0\Reset_Func_0_0_
B18E7416-3D1D-4595-BD28-E316EEB0A592.log"
Test Finished: 12/02/23  08:59a
Elapsed Time: 00 Days 00:00:01

------------------------------------------------------------
  Remaining test cases: 419
Zqemu: virtio: bogus descriptor or out of resources
QEMU: Terminated


------------------------------------------------------------
ReadBlocks_Conf
Revision 0x00010000
Test Entry Point GUID: 826159D3-04A5-4CCE-8431-344707A8B57A
Test Support Library GUIDs:
  1F9C2AE7-F147-4D19-A5E8-255AD005EB3E
------------------------------------------------------------
UEFI 2.6
Test Configuration #0
------------------------------------------------------------
Perform auto consistency checkes on the ReadBlocks interface
------------------------------------------------------------
Logfile: "\Sct\Log\MediaAccessTest\BlockIOProtocolTest0\ReadBlocks_Conf_1_0_826159D3-04A5-4CCE-8431-
344707A8B57A.log"
Test Started: 12/02/23  08:41a
------------------------------------------------------------
Current Device: Acpi(PNP0A03,0)/Pci(3|0)/HD(Part1,Sig7571DCCE-C5BB-4BBE-9975-46074C9E97CC)
qemu: virtio: bogus descriptor or out of resources
QEMU: Terminated
