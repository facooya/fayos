# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate memory

.section .text
.code16
.global alloc_mem

# alloc_mem()
# <ret> dx:ax = seg:off
# <ret> memnum
alloc_mem:
	push %si

	mov $mem_bitmap, %si
	add $0x01, %si # skip 0x0000 segment

	xor %ax, %ax # init
	xor %cx, %cx # byte count
	add $0x01, %cx
	xor %dx, %dx # bit count

.chk_byte__lp:
	# (byte != full)
	mov (%si), %al
	cmp $0xFF, %al
	jne .chk_bit__lp

	# {lp}
	add $0x01, %si
	add $0x01, %cx
	jmp .chk_byte__lp

.chk_bit__lp:
	# {end} (bit != 1)
	bt %dx, %ax
	jnc .chk_bit__end

	# {lp}
	add $0x01, %dx
	jmp .chk_bit__lp

.chk_bit__end:
	# set
	bts %dx, %ax
	mov %al, (%si)

	# calc memnum
	push %cx
	push %dx
	xor %dx, %dx
	mov %cx, %ax # byte count
	mov $0x08, %cx
	mul %cx
	pop %dx
	pop %cx
	add %dx, %ax # memnum

	# {{{ return
	mov %ax, (memnum)

	# calc offset (ax)
	push %cx
	mov %dx, %ax # bit count
	xor %dx, %dx
	mov $0x1000, %cx
	mul %cx # ax *= cx
	pop %cx

	# calc segment (dx)
	push %ax
	xor %dx, %dx
	mov %cx, %ax # byte count
	mov $0x1000, %cx
	mul %cx # ax *= cx
	mov %ax, %dx
	pop %ax
	# }}}

	pop %si
	ret
