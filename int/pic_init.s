# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Programmable interrupt controller initialization

# reference link
# http://wiki.osdev.org/8259_PIC

.section .text
.code16
.global pic_init

# pic_init()
pic_init:
	# 0x20 master PIC
	# 0xA0 slave PIC
	# init
	mov $0x11, %al # ICW1_INIT+ICW1_ICW4
	out %al, $0x20
	out %al, $0x80
	out %al, $0xA0
	out %al, $0x80

	# IRQ remap 0x20-0x2F
	mov $0x20, %al
	out %al, $0x21
	out %al, $0x80
	mov $0x28, %al
	out %al, $0xA1
	out %al, $0x80

	# connect
	mov $0x04, %al
	out %al, $0x21
	out %al, $0x80
	mov $0x02, %al
	out %al, $0xA1
	out %al, $0x80

	mov $0x01, %al # ICW4_8086
	out %al, $0x21
	out %al, $0x80
	out %al, $0xA1
	out %al, $0x80

	mov $0xFF, %al
	out %al, $0x21
	out %al, $0xA1

	# enable irq 1
	in $0x21, %al
	and $0xFD, %al
	out %al, $0x21

	# { rtc
	in $0xA1, %al
	and $~(0x01<<0x00), %al
	out %al, $0xA1

	in $0x21, %al
	and $~(0x01<<0x02), %al
	out %al, $0x21
	# }

	ret
