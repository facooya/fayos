# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Detect keyboard scan code

.section .text
.code16
.global kbd_scan_set
.global off_translate

# KD 0x60
# KS 0x64
# kbd_scan_set()
kbd_scan_set:
	pusha

	xor %ax, %ax

	# {{{ scan off
	mov $0xF5, %al
	out %al, $0x60

.lp0:
	in $0x64, %al
	test $0x02, %al
	jnz .lp0

	in $0x60, %al
	# }}}

	push %ax
	call dbg_reg
	add $0x02, %sp

.lp:
	in $0x64, %al
	test $0x02, %al
	jnz .lp

	mov $0xF0, %al
	out %al, $0x60

.lp2:
	in $0x64, %al
	test $0x01, %al
	jz .lp2

	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp

.lp3:
	in $0x64, %al
	test $0x02, %al
	jnz .lp3

	mov $0x00, %al
	out %al, $0x60

.lp4:
	in $0x64, %al
	test $0x01, %al
	jz .lp4

	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp

.lp5:
	in $0x64, %al
	test $0x01, %al
	jz .lp5

	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp

	mov $0xF4, %al
	out %al, $0x60

	in $0x60, %al

.done:
	popa
	ret

off_translate:
	pusha
	xor %ax, %ax

	mov $0x20, %al
	out %al, $0x64

.lp_:
	in $0x64, %al
	test $0x02, %al
	jnz .lp_

	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp

	and $0xBF, %al

	push %ax
	mov $0x60, %al
	out %al, $0x64
	pop %ax

	out %al, $0x60

	popa
	ret
