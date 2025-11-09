# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Create file

.include "chr.s"
.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/de.s"
.include "fs/ind.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
# <req> args, path_cv, path_sbuf
cmd_touch:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %si

	# (argc == 1) ? {err}
	mov (%si), %ax
	cmp $0x01, %ax
	je .err_arg_req

	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

	push $F_TYPE_FILE # (f_type)
	push %si # (&path)
	call fs_add
	add $0x04, %sp
	# <ax = {done:0, false:1}>

	# (fs_add() == done) ? {done} : {exit}
	test %ax, %ax
	jz .done
	jmp .exit

# {DONE}
.done:
	xor %ax, %ax
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# {ERR}
.err_arg_req:
	push $emsg_arg_req
	jmp .err_hdl

.err_hdl:
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
