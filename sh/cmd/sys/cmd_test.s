# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Test runtime

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %bx

	# set bit 1, bit 2
	mov $0x0B, %al
	out %al, $0x70
	mov $0x06, %al
	out %al, $0x71

.chk_uip:
	mov $0x0A, %al
	out %al, $0x70
	in $0x71, %al
	test $0x80, %al
	jnz .chk_uip

	# sec
	mov $0x00, %al
	out %al, $0x70
	in $0x71, %al
	mov %al, %bh

	# min
	mov $0x02, %al
	out %al, $0x70
	in $0x71, %al
	mov %al, %bl

	# hour
	mov $0x04, %al
	out %al, $0x70
	in $0x71, %al
	mov %al, %ch

	# day
	mov $0x07, %al
	out %al, $0x70
	in $0x71, %al
	mov %al, %cl

	# month
	mov $0x08, %al
	out %al, $0x70
	in $0x71, %al
	mov %al, %dh

	# year
	mov $0x09, %al
	out %al, $0x70
	in $0x71, %al
	mov %al, %dl

	push %bx
	call dbg_reg
	add $0x02, %sp
	push %cx
	call dbg_reg
	add $0x02, %sp
	push %dx
	call dbg_reg
	add $0x02, %sp

.done:
	pop %bx
	ret

