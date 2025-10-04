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
	mov (kbd_keymap_stat), %cx

	# (data == brk) ? {skip}
	cmp $PS2_SC_BRK, %al
	je .skip

	# (data == ext) ? {ext}
	cmp $PS2_SC_EXT, %al
	je .ext

	# (data == lshf) ? {lshf.set}
	cmp $PS2_SC_LSHF, %al
	je .lshf__set
	# (data == rshf) ? {rshf.set}
	cmp $PS2_SC_RSHF, %al
	je .rshf__set
	# (data == caps) ? {caps.set}
	cmp $PS2_SC_CAPS, %al
	je .caps__set

	# TODO: ctrl, alt, ...
	jmp .done

.skip:
	OBF
	in $PS2_DATA_REG, %al

	# (data == lshf) ? {lshf.clr} : {done}
	cmp $PS2_SC_LSHF, %al
	je .lshf__clr
	# (data == rshf) ? {rshf.clr} : {done}
	cmp $PS2_SC_RSHF, %al
	je .rshf__clr
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

# {SHF}
.lshf__set:
	or $(0x01<<0x00), %cx
	jmp .com__set

.lshf__clr:
	and $~(0x01<<0x00), %cx
	jmp .com__clr

.rshf__set:
	or $(0x01<<0x01), %cx
	jmp .com__set

.rshf__clr:
	and $~(0x01<<0x01), %cx
	jmp .com__clr

.caps__set:
	test $(0x01<<0x02), %cx
	jnz .caps__clr
	or $(0x01<<0x02), %cx
	jmp .com__set

.caps__clr:
	and $~(0x01<<0x02), %cx
	jmp .com__clr

.com__set:
	mov %cx, (kbd_keymap_stat)
	xor %ax, %ax
	jmp .done

.com__clr:
	mov %cx, (kbd_keymap_stat)
	xor %ax, %ax
	jmp .done

.done:
	ret
