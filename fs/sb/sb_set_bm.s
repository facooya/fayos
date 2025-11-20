# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Set bitmap

.include "drv/disk.s"
.section .text
.code16
.global sb_set_bm

# sb_set_bm()
sb_set_bm:
	push %es
	push %si
	push %bx

	# {{{ bbm
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	xor %ax, %ax
	push %ax
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	# }}}

	# {{{ ibm
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	xor %ax, %ax
	push %ax
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_IBM
	call disk_write_dpi
	add $0x02, %sp
	# }}}

	pop %bx
	pop %si
	pop %es
	ret
