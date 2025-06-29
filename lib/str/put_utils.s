# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put utilities in write buffer

.include "chr.s"
.section .text
.code16
.global putc
.global putnl
.global putsp

# putc()
# <REQ>
# al = chr
putc:
	push %si

	# {init}
	mov $write_buf, %si
	mov (%si), %dx # buf.len
	add $0x02, %si # skip len
	add %dx, %si # buf.in

	# store data
	mov %al, (%si)
	add $0x01, %dx

	# store len
	mov $write_buf, %si
	mov %dx, (%si)

	pop %si
	ret

# putnl()
putnl:
	push %si

	# {init}
	mov $write_buf, %si
	mov (%si), %dx # buf.len
	add $0x02, %si # skip len
	add %dx, %si # buf.in

	# store data
	mov $CHR_CR, %al
	mov %al, (%si)
	add $0x01, %si
	add $0x01, %dx

	mov $CHR_LF, %al
	mov %al, (%si)
	add $0x01, %dx

	# store len
	mov $write_buf, %si
	mov %dx, (%si)

	pop %si
	ret

# putsp()
putsp:
	push %si

	# {init}
	mov $write_buf, %si
	mov (%si), %dx # buf.len
	add $0x02, %si # skip len
	add %dx, %si # buf.in

	# store data
	mov $CHR_SP, %al
	mov %al, (%si)
	add $0x01, %dx

	# store len
	mov $write_buf, %si
	mov %dx, (%si)

	pop %si
	ret
