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

	cmp $0xF0, %al
	je .skip

	cmp $0xE0, %al
	je .read_extend_key

	mov $keymap, %si

	# scan_code to ascii
	add %ax, %si
	mov (%si), %al
	jmp .done

.skip:
	call ._obf
	in $0x60, %al
	xor %ax, %ax
	jmp .done

.read_extend_key:
	mov $extend_keymap, %si

	call ._obf
	in $0x60, %al

	cmp $0xF0, %al
	je .skip_extend

	# extend_code
	add %ax, %si
	mov (%si), %al

	mov $0xE0, %ah
	jmp .done

.skip_extend:
	call ._obf
	in $0x60, %al
	xor %ax, %ax
	jmp .done

.done:
	pop %si
	ret

._obf:
	in $0x64, %al
	test $0x01, %al
	jz ._obf
	ret
