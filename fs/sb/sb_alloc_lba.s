# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Allocate LBA

.include "fs/fs.s"
.include "fs/sb.s"
.section .text
.code16
.global sb_alloc_lba

# sb_alloc_lba(ub16 *seg, ub16 *off)
sb_alloc_lba:
	push %bp
	mov %sp, %bp
	push %es
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)

	mov %es:SB_OFF_TOT_SECT(%bx), %ax
	mov %es:SB_OFF_TOT_SECT+0x02(%bx), %dx
	test %dx, %dx
	jz .low
	# TODO: log over 16-bit

.low:
	# {{{
	# bbs
	xor %dx, %dx
	mov $0x40, %cx
	div %cx
	mov %ax, %es:SB_OFF_BBM_SIZE(%bx)

	# ibs
	mov %es:SB_OFF_BBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $0x04, %cx
	div %cx
	mov %ax, %es:SB_OFF_IBM_SIZE(%bx)

	# its
	mov %es:SB_OFF_BBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $0x40, %cx
	mul %cx
	mov %ax, %es:SB_OFF_IT_SIZE(%bx)
	# }}}

	# {{{
	# bbbc
	mov %es:SB_OFF_BBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $0x1000, %cx
	div %cx

	test %dx, %dx
	jz .set_bbbc
	add $0x01, %ax

.set_bbbc:
	mov %ax, %es:SB_OFF_BBM_BC(%bx)

	# ibbc
	mov %es:SB_OFF_IBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $0x1000, %cx
	div %cx

	test %dx, %dx
	jz .set_ibbc
	add $0x01, %ax

.set_ibbc:
	mov %ax, %es:SB_OFF_IBM_BC(%bx)

	# itbc
	mov %es:SB_OFF_IT_SIZE(%bx), %ax
	xor %dx, %dx
	mov $0x1000, %cx
	div %cx

	test %dx, %dx
	jz .set_itbc
	add $0x01, %ax

.set_itbc:
	mov %ax, %es:SB_OFF_IT_BC(%bx)
	# }}}
	
	# {{{
	# bb
	mov $FS_START_LBA, %ax
	mov %ax, %es:SB_OFF_BBM_LBA(%bx)

	# ib
	mov %es:SB_OFF_BBM_BC(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov %es:SB_OFF_BBM_LBA(%bx), %cx
	add %cx, %ax
	mov %ax, %es:SB_OFF_IBM_LBA(%bx)

	# it
	mov %es:SB_OFF_IBM_BC(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov %es:SB_OFF_IBM_LBA(%bx), %cx
	add %cx, %ax
	mov %ax, %es:SB_OFF_IT_LBA(%bx)

	# normal
	mov %es:SB_OFF_IT_BC(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov %es:SB_OFF_IT_LBA(%bx), %cx
	add %cx, %ax
	mov %ax, %es:SB_OFF_NORM_LBA(%bx)
	# }}}

	pop %bx
	pop %es
	pop %bp
	ret
