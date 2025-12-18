# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ps2.s"
.section .text
.code16
.global isr_ps2

# irq 0x01
isr_ps2:
	push %ax

	# (init_flag != 0) ? {skip}
	mov (init_flag), %ax
	test %ax, %ax
	jnz .skip

	in $PS2_PORT_DATA, %al
	cmp $PS2_SC_BRK, %al
	je .brk
	cmp $PS2_SC_EXT, %al
	je .ext
	jmp .norm

.brk:
	mov (scancode+0x01), %ah
	or $PS2_SCF_BRK, %ah
	mov %ah, (scancode+0x01)
	jmp .done

.ext:
	mov (scancode+0x01), %ah
	or $PS2_SCF_EXT, %ah
	mov %ah, (scancode+0x01)
	jmp .done

.norm:
	mov %al, (scancode)
	jmp .done

.skip:
	in $PS2_PORT_DATA, %al
	jmp .done

.done:
	mov $EOI, %al
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret
