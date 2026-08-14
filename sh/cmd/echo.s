# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.section .text
.code16
.global cmd_echo

# cmd_echo()
# (opt_flag: {0:escape, 1:no-newline})
# <INFO>
# si = &cl_sbuf
# di = &args
# bx = opt_flag
# cx = argc
cmd_echo:
	push %si
	push %di
	push %bx

	# {
	# get argc
	mov $arg_ccv, %di
	mov (%di), %cx # argc
	add $0x02, %di

	# get optc
	mov (%di), %bx # optc
	add $0x02, %di

	# calc
	mov %cx, %ax
	dec %ax # skip cmd
	sub %bx, %ax # skip optc

	# (argc == 0) ? {err}
	test %ax, %ax
	jz .err_arg_req
	# }

	# {
	# {init}
	mov $cl_sbuf, %si
	add $0x02, %si # skip len

	# {init}
	mov %bx, %ax # optc
	xor %bx, %bx # opt_flag
	add $0x02, %di # skip argv[0] (cmd)
	dec %cx # skip argv[0]

	# (optc == 0) ? {run} : {opt}
	test %ax, %ax
	jz .run
	jmp .opt
	# }

# (*si == hyphen)
# dx = optc
.opt:
	mov %ax, %dx # optc

	add (%di), %si # buf += argv[1]
	inc %si # skip hyphen

# (*si == opt_chr)
.opt__lp:
	mov (%si), %al

	# (opt_chr == e) ? {set_e}
	cmp $0x65, %al
	je .opt__set_e

	# (opt_chr == n) ? {set_n} : {err}
	cmp $0x6E, %al
	je .opt__set_n
	jmp .err_opt_inv

.opt__set_e:
	or $(0x01<<0x00), %bx
	jmp .opt__set_chk

.opt__set_n:
	or $(0x01<<0x01), %bx
	jmp .opt__set_chk

.opt__set_chk:
	inc %si

	# (opt_chr == null) ? {chk} : {lp}
	mov (%si), %al
	test %al, %al
	jz .opt__chk
	jmp .opt__lp

# (*si == null)
.opt__chk:
	# {step}
	dec %cx # argc
	dec %dx # optc

	# (optc == 0) ? {end}
	test %dx, %dx
	jz .opt__end

	add $0x02, %si # skip null+hyphen
	add $0x02, %di # argv[n+1]
	jmp .opt__lp

# (*si == null)
.opt__end:
	add $0x02, %di # argv[n+1]
	jmp .run

# (*di == arg_idx)
.run:
	# {init}
	mov $cl_sbuf, %si
	add $0x02, %si

	mov (%di), %ax # arg_idx
	add %ax, %si

.run__lp:
	# (opt == e) ? {exec_e}
	test $(0x01<<0x00), %bx
	jnz .run__exec_e

	push %si
	push %ds
	call puts
	add $0x04, %sp
	jmp .run__chk

.run__exec_e:
	push %si
	push %ds
	call putf
	add $0x04, %sp

.run__chk:
	dec %cx # argc

	# (arg_c == 0) ? {end}
	test %cx, %cx
	jz .run__end

	call putsp

	# {lp.init}
	mov $cl_sbuf, %si
	add $0x02, %si # skip len

	# {lp.step}
	add $0x02, %di # argv[n+1]
	mov (%di), %ax
	add %ax, %si
	jmp .run__lp

.run__end:
	# (opt == n) ? {done}
	xor %ax, %ax
	test $(0x01<<0x01), %bx
	jnz .done

	call putnl
	xor %ax, %ax
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret

.err_opt_inv:
	# print opt err
	mov (%si), %al # opt err char
	push %ax # (chr)
	call vga_outc
	add $0x02, %sp
	push $CHR_COL # (chr)
	call vga_outc
	add $0x02, %sp
	push $CHR_SP # (chr)
	call vga_outc
	add $0x02, %sp

	push $emsg_opt_inv
	jmp .err_hdl

.err_arg_req:
	push $emsg_arg_req
	jmp .err_hdl

.err_hdl:
	movb $ATTR_ERR, (vga_attr)
	call vga_outs
	add $0x02, %sp

	NEWLINE

	mov $0x01, %ax
	jmp .done
