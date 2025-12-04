# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.section .text
.code16
.global ata_init

# ata_init()
ata_init:
	# int enable
	mov $ATA_DCR, %dx
	in %dx, %al
	and $~ATA_DCR_NIEN, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al
	ret
