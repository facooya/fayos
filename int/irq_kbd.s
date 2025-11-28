# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Interrupt request from keyboard

.include "int.s"
.include "drv/ps2.s"
.section .text
.code16
.global irq_kbd

# irq 0x01
irq_kbd:
	push %ax

	mov (init_flag), %ax
	test %ax, %ax
	jnz .skip

	in $PS2_DATA_REG, %al

	cmp $PS2_SC_BRK, %al
	je .brk
	cmp $PS2_SC_EXT, %al
	je .ext
	jmp .norm

.brk:
	mov (scan_code+0x01), %ah
	or $PS2_SC_BIT_BRK, %ah
	mov %ah, (scan_code+0x01)
	jmp .done

.ext:
	mov (scan_code+0x01), %ah
	or $PS2_SC_BIT_EXT, %ah
	mov %ah, (scan_code+0x01)
	jmp .done

.norm:
	mov %al, (scan_code)
	jmp .done

.skip:
	in $PS2_DATA_REG, %al
	jmp .done

.done:
	mov $EOI, %al
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret
