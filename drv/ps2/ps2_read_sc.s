# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read scan code

.include "drv/ps2.s"
.section .text
.code16
.global ps2_read_sc

# ps2_read_sc()
# <ret> ax = scan_code
ps2_read_sc:
	push %si

	xor %ax, %ax
	OBF
	in $PS2_DATA_REG, %al

	cmp $PS2_SC_BRK, %al
	je .skip

	cmp $PS2_SC_EXT, %al
	je .read_ext_key

	mov $keymap, %si

	# scan_code to ascii
	add %ax, %si
	mov (%si), %al
	jmp .done

.skip:
	OBF
	in $PS2_DATA_REG, %al
	xor %ax, %ax
	jmp .done

.read_ext_key:
	mov $extend_keymap, %si

	OBF
	in $PS2_DATA_REG, %al

	cmp $PS2_SC_BRK, %al
	je .skip_ext

	# extend_code
	add %ax, %si
	mov (%si), %al

	mov $PS2_SC_EXT, %ah
	jmp .done

.skip_ext:
	OBF
	in $PS2_DATA_REG, %al
	xor %ax, %ax
	jmp .done

.done:
	pop %si
	ret
