# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Interrupt request from keyboard

.section .text
.code16
.global irq_kbd

# irq 0x01 || int $0x21
irq_kbd:
	call ps2_read_sc

	# (sc == null) ? {done}
	test %ax, %ax
	jz .done

	call kbd_sctokc
	call kbd_main

.done:
	# EOI
	mov $0x20, %al
	out %al, $0x20
	iret
