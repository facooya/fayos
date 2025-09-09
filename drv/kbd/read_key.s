# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read key

.section .text
.code16
.global read_key

# read_key()
# <ret> al = ascii
read_key:
	push %si

	mov $keymap, %si
	xor %ax, %ax

	call ._obf
	in $0x60, %al

	# scan_code to ascii
	add %ax, %si
	mov (%si), %al

	# HACK
	push %ax
	call ._obf # 0xF0
	in $0x60, %al
	call ._obf # scan_code
	in $0x60, %al
	pop %ax

	pop %si
	ret

._obf:
	in $0x64, %al
	test $0x01, %al
	jz ._obf
	ret
