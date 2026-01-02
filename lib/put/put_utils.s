# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put utilities in write buffer

.include "chr.inc"
.section .text
.code16
.global putc
.global putnl
.global putsp

# putc()
# <req> al = chr
putc:
	push %si
	push %bx

	# {init}
	mov $write_sbuf, %si
	mov (%si), %bx # buf.size
	add $0x02, %si # skip size
	add %bx, %si # buf.in

	# store data
	mov %al, (%si)
	add $0x01, %bx

	# store size
	mov $write_sbuf, %si
	mov %bx, (%si)

	pop %bx
	pop %si
	ret

# putnl()
putnl:
	push %si
	push %bx

	# {init}
	mov $write_sbuf, %si
	mov (%si), %bx # buf.size
	add $0x02, %si # skip size
	add %bx, %si # buf.in

	# store data
	mov $CHR_CR, %al
	mov %al, (%si)
	add $0x01, %si
	add $0x01, %bx

	mov $CHR_LF, %al
	mov %al, (%si)
	add $0x01, %bx

	# store size
	mov $write_sbuf, %si
	mov %bx, (%si)

	pop %bx
	pop %si
	ret

# putsp()
putsp:
	push %si
	push %bx

	# {init}
	mov $write_sbuf, %si
	mov (%si), %bx # buf.size
	add $0x02, %si # skip size
	add %bx, %si # buf.in

	# store data
	mov $CHR_SP, %al
	mov %al, (%si)
	add $0x01, %bx

	# store size
	mov $write_sbuf, %si
	mov %bx, (%si)

	pop %bx
	pop %si
	ret
