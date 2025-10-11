# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Bootloader

.include "boot.s"
.section .data
.bmsg_fayos: .asciz "FAYOS\n"

.section .text
.code16
.global _start

# _start()
_start:
	# init
	cli
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov %ax, %sp
	mov %ax, %bp

	# set stack
	mov $STACK_PTR, %sp

	# display
	call clear_disp
	push $.bmsg_fayos
	call out_msg
	add $0x02, %sp

	# kernel
	mov $KERN_OFF, %di
	call read_kernel
	ljmp $KERN_SEG, $KERN_OFF
