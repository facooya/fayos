# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove directory

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global cmd_rmdir

# cmd_rmdir()
cmd_rmdir:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %di

	# (argc == 1) ? {err}
	mov (%di), %cx
	cmp $0x01, %cx
	je .err_arg_req
	add $0x06, %di # skip arg_c, opt_c, cmd
	dec %cx # tgt_c

.lp:
	# (tgt_c == 0) ? {done}
	test %cx, %cx
	jz .done

	mov (%di), %ax # argv[1+i]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1+i]]

	push %cx # [s.f0:tgt_c]
	push $F_TYPE_DIR # (f_type)
	push %si # (&path)
	call fs_rm
	add $0x04, %sp
	# <ax = {done:0, false:1}>
	pop %cx # [s.f0:tgt_c]

	# (fs_rm() != done) ? {err} : {lp}
	test %ax, %ax
	jnz .exit
	add $0x02, %di
	dec %cx
	jmp .lp

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
