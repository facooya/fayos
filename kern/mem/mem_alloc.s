# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Memory] Allocate

.section .text
.code16
.global mem_alloc

# mem_alloc()
# <ret> dx:ax = seg:off
mem_alloc:
	push %si

	mov $mem_bm, %si
	add $0x02, %si # skip 0x0000 segment

	xor %cx, %cx # bit cnt
	xor %dx, %dx # word cnt
	inc %dx

.chk_word__lp:
	# (word != full) ? {bit.lp} : {lp}
	mov (%si), %ax
	cmp $0xFFFF, %ax
	jne .chk_bit__lp

	add $0x02, %si
	inc %dx
	jmp .chk_word__lp

.chk_bit__lp:
	# (bit != set) ? {end} : {lp}
	bt %cx, %ax
	jnc .chk_bit__end

	inc %cx
	jmp .chk_bit__lp

.chk_bit__end:
	# set
	bts %cx, %ax
	mov %ax, (%si)
	mov %cx, %ax

	# ret
	shl $0x0C, %dx # seg
	shl $0x0C, %ax # off

	pop %si
	ret
