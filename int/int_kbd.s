# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Interrupt keyboard

.section .text
.code16
.global int_kbd

# KD 0x60
# KS 0x64
# PIC 0x20
# EOI 0x20
# int $0x31
int_kbd:
	call read_key
	call kbd_main

	# EOI
	mov $0x20, %al
	out %al, $0x20
	iret
