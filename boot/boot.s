# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Boot for Fayos (docs/boot/boot.txt)

.code16
.global _start

# _start()
_start:
	cli # [n_cli]

	# init [n_init]
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov %ax, %bx
	mov %ax, %cx
	mov %ax, %dx
	mov %ax, %bp

	# set stack [n_stack]
	mov $0x7C00, %sp

	push $.os_name_str
	call .out_str
	add $0x02, %sp

	# kernel
	call .read_block
	ljmp $0x0000, $0x1000

# .read_block()
.read_block:
	# prol
	push %si
	push %ax
	push %dx

	# read block
	clc
	mov $0x42, %ah
	mov $0x80, %dl
	mov $.dap, %si
	int $0x13
	jc .read_block__err

	push $.boot_ok_msg
	call .out_str
	add $0x02, %sp

	# epil
	pop %dx
	pop %ax
	pop %si
	ret

.read_block__err:
	push $.boot_err_msg
	call .out_str
	add $0x02, %sp

	# epil
	pop %dx
	pop %ax
	pop %si
	hlt

# .out_str(str)
.out_str:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	mov 4(%bp), %si
	mov $0x0E, %ah

.out_str__lp:
	# cond: null ? done
	mov (%si), %al
	test %al, %al
	jz .out_str__done

	int $0x10

	# loop
	add $0x01, %si
	jmp .out_str__lp

.out_str__done:
	# epil
	pop %ax
	pop %si
	pop %bp
	ret

# data
.os_name_str: .asciz "\nFAYOS\r\n"
.boot_ok_msg: .asciz "Boot ok\r\n"
.boot_err_msg: .asciz "Boot err\r\n"

# dap [n_dap]
.dap:
	.byte 0x10
	.byte 0x00
	.word 0x30
	.word 0x1000
	.word 0x0000
	.word 0x20
	.word 0x00
	.word 0x00
	.word 0x00

# end [n_end]
.fill 0x01FE-(.-_start), 0x01, 0x00
.word 0xAA55
