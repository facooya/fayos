# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Out character 2

.section .text
.code16
.global outc2

# outc2()
# <req> al = chr
outc2:
	push %es
	push %di

	# TODO get cursor

	# init
	mov $0xB000, %dx
	mov %dx, %es
	mov $0x8000, %di

	# out
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	pop %di
	pop %es
	ret
