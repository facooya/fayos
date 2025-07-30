# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Bootloader

.code16
.global _start

# _start()
_start:
	# clear interrupt
	cli

	# init
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov %ax, %sp
	mov %ax, %bp
	mov %ax, %si
	mov %ax, %di
	mov %ax, %bx
	mov %ax, %cx
	mov %ax, %dx

	# set stack
	mov $0x7C00, %sp

	call .clear_disp
	push $.bmsg_fayos
	call .out_str
	add $0x02, %sp

	# kernel
	call .read_kernel_disk
	ljmp $0x0000, $0x1000

# .read_kernel_disk()
.read_kernel_disk:
	push %si
	push %ax
	push %dx

	clc
	mov $0x42, %ah
	mov $0x80, %dl
	mov $.dap, %si
	int $0x13
	jc .read_kernel_disk__err

	push $.bmsg_kd_ok
	call .out_str
	add $0x02, %sp

	pop %dx
	pop %ax
	pop %si
	ret

.read_kernel_disk__err:
	push $.bmsg_kd_err
	call .out_str
	add $0x02, %sp

	pop %dx
	pop %ax
	pop %si
	hlt

# .out_str(&str)
.out_str:
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	mov 0x04(%bp), %si
	mov $0x0E, %ah

.out_str__lp:
	# {end} (chr == null)
	mov (%si), %al
	test %al, %al
	jz .out_str__end

	int $0x10

	# {lp}
	add $0x01, %si
	jmp .out_str__lp

.out_str__end:
	pop %ax
	pop %si
	pop %bp
	ret

# .clear_disp()
.clear_disp:
	push %ax
	push %bx
	push %cx
	push %dx

	# _sys_get_cursor
	mov $0x03, %ah
	xor %bh, %bh
	int $0x10 # dh = scroll_up_end_y

	# _sys_get_mode
	mov $0x0F, %ah
	int $0x10
	mov %ah, %dl # vid_end_x

	# _sys_scroll_up
	mov $0x06, %ah
	xor %al, %al
	mov $0x07, %bh
	xor %cx, %cx
	int $0x10

	# _sys_set_cursor
	xor %dx, %dx # cursor(0,0)
	mov $0x02, %ah
	xor %bh, %bh
	int $0x10

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	ret

# bmsg
.bmsg_fayos: .asciz "\nFAYOS\r\n"
.bmsg_kd_ok: .asciz "Kernel disk read ok\r\n"
.bmsg_kd_err: .asciz "kernel disk read error\r\n"

# dap
.dap:
	.byte 0x10
	.byte 0x00
	.word 0x30
	.word 0x1000
	.word 0x0000
	.word 0x10
	.word 0x00
	.word 0x00
	.word 0x00

# end
.fill 0x01FE-(.-_start), 0x01, 0x00
.word 0xAA55
