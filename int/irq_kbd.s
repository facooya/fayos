# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Interrupt request from keyboard

.section .text
.code16
.global irq_kbd

# int $0x21
irq_kbd:
	call read_key
	test %ax, %ax
	jz .pass

	call kbd_main

.pass:
	# EOI
	mov $0x20, %al
	out %al, $0x20
	iret
