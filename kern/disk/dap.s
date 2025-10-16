# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet

.include "dap.s"
.global dap
.global dap_es

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
