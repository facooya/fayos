# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Interrupt request from keyboard

.include "drv/ps2.s"
.section .text
.code16
.global irq_kbd

# irq 0x01 || int $0x21
irq_kbd:
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

.done:
	# EOI
	mov $0x20, %al
	out %al, $0x20
	iret
