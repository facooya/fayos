# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Bootloader

.include "boot_equ.s"
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
	mov $KERNEL_OFF, %di
	call read_kernel
	ljmp $KERNEL_SEG, $KERNEL_OFF

# {FUNC}
.include "out_msg.s"
.include "clear_disp.s"
.include "read_kernel.s"

# {DATA}
.bmsg_fayos: .asciz "FAYOS\n"

# {DONE}
.fill FILL_REP-(.-_start), FILL_SIZE, FILL_VAL
.word BOOT_SIG
