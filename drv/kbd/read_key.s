# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read key

.include "drv/ps2.s"
.section .text
.code16
.global read_key

# read_key()
# <ret> al = ascii
read_key:
	push %si

	xor %ax, %ax
	call ._obf
	in $PS2_DATA_REG, %al

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
	in $PS2_DATA_REG, %al
	xor %ax, %ax
	jmp .done

.read_extend_key:
	mov $extend_keymap, %si

	call ._obf
	in $PS2_DATA_REG, %al

	cmp $0xF0, %al
	je .skip_extend

	# extend_code
	add %ax, %si
	mov (%si), %al

	mov $0xE0, %ah
	jmp .done

.skip_extend:
	call ._obf
	in $PS2_DATA_REG, %al
	xor %ax, %ax
	jmp .done

.done:
	pop %si
	ret

._obf:
	in $PS2_STAT_REG, %al
	test $PS2_OBF, %al
	jz ._obf
	ret
