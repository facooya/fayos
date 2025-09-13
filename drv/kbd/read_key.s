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

	xor %ax, %ax
	call ._obf
	in $0x60, %al

	cmp $0xE0, %al
	je .read_extend_key

	mov $keymap, %si

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
	jmp .done

.read_extend_key:
	mov $extend_keymap, %si

	call ._obf
	in $0x60, %al

	# extend_code
	add %ax, %si
	mov (%si), %al

	# HACK
	push %ax
	call ._obf # 0xE0
	in $0x60, %al
	call ._obf # 0xF0
	in $0x60, %al
	call ._obf # scan_code
	in $0x60, %al
	pop %ax

	mov $0xE0, %ah
	jmp .done

.done:
	pop %si
	ret

._obf:
	in $0x64, %al
	test $0x01, %al
	jz ._obf
	ret
