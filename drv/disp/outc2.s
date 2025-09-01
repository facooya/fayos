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

	# init
	mov $0xB000, %dx
	mov %dx, %es
	mov $0x8000, %di

	push %ax # [s.0:chr]
	call get_cursor2
	mov %ax, %dx
	add %dx, %di
	add %dx, %di
	pop %ax # [s.0:chr]

	# out
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	add $0x01, %dx
	push %dx
	call set_cursor2
	add $0x02, %sp

	pop %di
	pop %es
	ret
