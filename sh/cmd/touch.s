# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Create file

.include "chr.s"
.include "drv/disk.inc"
.include "fs/fs.s"
.include "fs/de.s"
.include "fs/ind.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
# <req> arg_ccv, path_cv, path_sbuf
cmd_touch:
	push %es
	push %si
	push %di
	push %bx

	mov $arg_ccv, %di

	# (argc == 1) ? {err}
	mov (%di), %cx
	add $0x02, %di
	cmp $0x01, %cx
	je .err_arg_req
	add $0x04, %di # skip opt_c, cmd
	dec %cx # tgt_c

.lp:
	# (tgt_c == 0) ? {done}
	test %cx, %cx
	jz .done

	mov (%di), %ax # argv[1+i]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1]]

	push %cx # [s.f0:tgtc]
	push $F_TYPE_FILE # (f_type)
	push %si # (&path)
	call fs_add
	add $0x04, %sp
	# <ax = {done:0, false:1}>
	pop %cx # [s.f0:tgtc]

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
