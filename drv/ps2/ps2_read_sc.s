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
# <ret> dx = sc_brk
ps2_read_sc:
	xor %ax, %ax
	OBF
	in $PS2_DATA_REG, %al

	# (data == brk) ? {skip}
	cmp $PS2_SC_BRK, %al
	je .skip

	# (data == ext) ? {ext}
	cmp $PS2_SC_EXT, %al
	je .ext

	xor %dx, %dx
	jmp .done

.skip:
	OBF
	in $PS2_DATA_REG, %al

	xor %dx, %dx
	mov %al, %dl
	xor %ax, %ax
	jmp .done

.ext:
	OBF
	in $PS2_DATA_REG, %al

	# (data == brk) ? {skip} : {done}
	cmp $PS2_SC_BRK, %al
	je .ext__skip
	mov $PS2_SC_EXT, %ah
	xor %dx, %dx
	jmp .done

.ext__skip:
	OBF
	in $PS2_DATA_REG, %al

	xor %dx, %dx
	mov %al, %dl
	xor %ax, %ax
	jmp .done

.done:
	ret
