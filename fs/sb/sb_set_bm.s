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
	push %bx

	# {{{ bbm
	push $DNUM_BBM
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $DNUM_BBM
	call disk_write_sect
	add $0x02, %sp
	# }}}

	# {{{ ibm
	push $DNUM_IBM
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $DNUM_IBM
	call disk_write_sect
	add $0x02, %sp
	# }}}

	pop %bx
	pop %es
	ret
