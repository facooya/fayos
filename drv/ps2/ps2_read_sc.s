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
	xor %ax, %ax
	OBF
	in $PS2_DATA_REG, %al

	# (data == brk) ? {skip}
	cmp $PS2_SC_BRK, %al
	je .skip

	# (data == ext) ? {ext}
	cmp $PS2_SC_EXT, %al
	je .ext

	# (data == shf) ? {shf.set}
	cmp $PS2_SC_SHF, %al
	je .shf__set

	# TODO: ctrl, alt, ...
	jmp .done

.skip:
	OBF
	in $PS2_DATA_REG, %al

	# (data == shf) ? {shf.clr} : {done}
	cmp $PS2_SC_SHF, %al
	je .shf__clr
	xor %ax, %ax
	jmp .done

.ext:
	OBF
	in $PS2_DATA_REG, %al

	# (data == brk) ? {skip} : {done}
	cmp $PS2_SC_BRK, %al
	je .ext__skip
	mov $PS2_SC_EXT, %ah
	jmp .done

.ext__skip:
	OBF
	in $PS2_DATA_REG, %al
	xor %ax, %ax
	jmp .done

.shf__set:
	mov $0x01, %ax
	mov %ax, (kbd_keymap_stat)
	xor %ax, %ax
	jmp .done

.shf__clr:
	xor %ax, %ax
	mov %ax, (kbd_keymap_stat)
	jmp .done

.done:
	ret
