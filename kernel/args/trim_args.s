# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Trim arguments

.section .text
.code16
.global trim_args

.global dout # DEBUG!!!

# DEBUG!!!
dout:
	# prol
	push %si
	push %di
	push %bx

	call outnl

	# init
	mov $raw_buf, %si
	mov (%si), %cx
	add $0x02, %si

.dout__lp:
	cmp $0x00, %cx
	jle .dout__done

	mov (%si), %al

	cmp $0x20, %al
	je .dout__sp

	test %al, %al
	jz .dout__nul

	call sys_tty_out
	jmp .dout__step

.dout__sp:
	mov $'.', %al
	call sys_tty_out
	jmp .dout__step

.dout__nul:
	mov $'0', %al
	call sys_tty_out
	jmp .dout__step

.dout__step:
	add $0x01, %si
	sub $0x01, %cx
	jmp .dout__lp

.dout__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret

# trim_args()
trim_args:
	# prol
	push %si
	push %di
	push %bx

	# init
	mov $raw_buf, %si
	mov (%si), %cx
	add $0x02, %si
	
.trim_args__left:
	# load
	mov (%si), %al

	# (raw_buf[off] != space) ? left_end {end}
	cmp $0x20, %al
	jne .trim_args__left_end

	# step {loop}
	add $0x01, %si
	sub $0x01, %cx
	jmp .trim_args__left

.trim_args__left_end:
	# cpy
	mov %si, %di
	add %cx, %di
	sub $0x01, %di
	# si = fst valid idx
	# di = last idx

.trim_args__right:
	# load
	mov (%di), %al

	# (raw_buf[off] != space) ? {end}
	cmp $0x20, %al
	jne .trim_args__right_end

	# step {loop}
	sub $0x01, %di
	sub $0x01, %cx
	jmp .trim_args__right

.trim_args__right_end:
	# init
	mov $raw_buf, %di
	mov %cx, (%di)
	add $0x02, %di

.trim_args__cpy:
	# (len <= 0) ? {end}
	cmp $0x00, %cx
	jle .trim_args__cpy_end

	# cpy
	mov (%si), %al
	mov %al, (%di)

	# step {loop}
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cx
	jmp .trim_args__cpy

.trim_args__cpy_end:
	call dout # DEBUG!!!

.trim_args__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret
