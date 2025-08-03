# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet

.include "fayfs/super.s"
.include "dap.s"
.global dap
.global dap_es
.global dap_super
.global dap_bb
.global dap_ib
.global dap_it

# Mutable
dap:
	.byte DAP_SIZE
	.byte DAP_RESV
	.word DAP_SECTOR_COUNT
	.word 0x8000
	.word 0x1000
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00

dap_es:
	.byte DAP_SIZE
	.byte DAP_RESV
	.word DAP_SECTOR_COUNT
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00

# Immutable
dap_super:
	.byte DAP_SIZE
	.byte DAP_RESV
	.word S_SECTOR_COUNT
	.word S_OFF_MEM
	.word S_SEG_MEM
	.word (S_LBA&0xFFFF)
	.word (S_LBA>>0x10)
	.word 0x00
	.word 0x00

# Mutable LBA by superblock
dap_bb:
	.byte DAP_SIZE
	.byte DAP_RESV
	.word DAP_SECTOR_COUNT
	.word 0x00
	.word 0x1000
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00

dap_ib:
	.byte DAP_SIZE
	.byte DAP_RESV
	.word DAP_SECTOR_COUNT
	.word 0x1000
	.word 0x1000
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00

dap_it:
	.byte DAP_SIZE
	.byte DAP_RESV
	.word DAP_SECTOR_COUNT
	.word 0x2000
	.word 0x1000
	.word 0x00
	.word 0x00
	.word 0x00
	.word 0x00
