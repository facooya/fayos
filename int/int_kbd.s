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
	pusha

	xor %ax, %ax
	inb $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp

	mov $0x20, %al
	outb %al, $0x20

	popa
	iret
