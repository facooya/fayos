# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Set disk input/output structure

.section .text
.code16
.global disk_set_dio

# disk_set_dio(ub32 *blknum, ub16 dnum)
# <req> dio
disk_set_dio:
	push %si
	push %di
	push %bx

	mov $dio, %di

	# TODO: allocate memory seg:off - es:di

	# TODO: blknum hi lo calc
	mov 0x02(%si), %ax
	mov (%si), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx

	# [lba_lo + NORM_LBA]
	#mov $S_OFF_MEM, %bx
	#mov NORM_LBA_OFF(%bx), %cx
	#clc
	#add %cx, %ax
	#jnc .ncf
	#add $0x01, %dx

	pop %bx
	pop %di
	pop %si
	ret
