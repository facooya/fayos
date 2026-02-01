# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "fs/de.inc"
.section .text
.code16
.global cmd_ls

# cmd_ls()
# (opt_flag: {0:a:all})
cmd_ls:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	xor %ax, %ax
	mov %ax, -0x04(%bp) # (l.2: opt_flg)
	mov $arg_ccv, %si
	mov (%si), %ax # argc
	mov 0x02(%si), %cx # optc
	mov %cx, -0x02(%bp) # (l.1: optc)
	mov %cx, -0x06(%bp) # (l.3: optc_tmp)
	sub %cx, %ax

	# ((argc-optc) == 1) ? {cmd_only}
	cmp $0x01, %ax
	je .cmd_only

	# { get path vector
	add $0x06, %si # skip argc, optc, argv[1]
	add %cx, %si
	add %cx, %si

	mov (%si), %ax # argv[path]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[path]]
	# }

	# { path
	push %si # (&name)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je .err_inv_path
	# (path_parse() == neq_last) ? {err}
	cmp $0x02, %ax
	je .err_dir_no
	# }

	# (f_type != dir) ? {err}
	mov $fsp+FSP_OFF_BASE, %di
	mov FSP_OFF_F_TYPE(%di), %al
	cmp $F_TYPE_DIR, %al
	jne .err_dir_type

	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %dx
	push %dx # [s.f0: f_size]
	push %dx # (size)
	push $0x00 # (idx)
	push %si # (fsp &src)
	call fs_read
	add $0x06, %sp
	pop %dx # [s.f0: f_size]

	# (optc == 0) ? {run} : {opt}
	mov -0x02(%bp), %ax # (l.1: optc)
	test %ax, %ax
	jz .run
	jmp 10f

.cmd_only:
	mov $fsp+FSP_OFF_CUR, %si
	mov FSP_OFF_F_SIZE(%si), %dx
	push %dx # [s.f0: f_size]
	push %dx # (size)
	push $0x00 # (idx)
	push %si # (fsp &src)
	call fs_read
	add $0x06, %sp
	pop %dx # [s.f0: f_size]

	# (optc == 0) ? {run} : {opt}
	mov -0x02(%bp), %ax # (l.1: optc)
	test %ax, %ax
	jz .run
	jmp 10f

10: # opt
	mov $arg_ccv, %si
	add $0x06, %si # skip argc, optc, argv[0]

	mov (%si), %ax # optv[0]
	mov $cl_sbuf, %di
	add $0x02, %di
	add %ax, %di # cl_sbuf[optv[0]]
	inc %di # skip hyp

11:
	# (opt == a) ? {set_a}
	mov (%di), %al # opt_chr
	cmp $0x61, %al
	je 1001f
	jmp 8001f # opt err

1001: # opt a
	mov -0x04(%bp), %ax # (l.2: opt_flg)
	or $(0x01<<0x00), %ax
	mov %ax, -0x04(%bp)
	jmp 12f

12:
	# (next_opt == null) ? {chk_end} : {lp}
	inc %di
	mov (%di), %al
	test %al, %al
	jz 13f
	jmp 11b

13:
	mov -0x06(%bp), %ax # (l.3: optc_tmp)
	dec %ax
	mov %ax, -0x06(%bp) # (l.3: optc_tmp)
	test %ax, %ax
	jz .run

	add $0x02, %di # skip null, hyphen
	jmp 11b

.run:
	mov $fs_read_buf, %bx
	mov %bx, %si

.run__lp:
	# (inum == 0) ? {chk}
	mov DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	jz .run__lp_step

	# set name ptr
	mov %bx, %si
	add $DE_OFF_NAME, %si

	# (opt == a) ? {pass}
	mov -0x04(%bp), %ax # (l.2: opt_flg)
	test $(0x01<<0x00), %ax
	jnz 1f

	# (name_start == dot) ? {cont}
	mov (%si), %al
	cmp $CHR_PRD, %al
	je .run__lp_step

1:
	# (f_type == dir) ? {dir} : {std}
	mov DE_OFF_F_TYPE(%bx), %cl
	cmp $F_TYPE_DIR, %cl
	je 1f
	jmp 2f

1:
	mov $ATTR_MARK, %al
	call putc
	mov $ATTR_DIR, %al
	call putc
	jmp 3f

2:
	mov $ATTR_MARK, %al
	call putc
	mov $ATTR_STD, %al
	call putc
	jmp 3f

3:
	# get name size
	xor %cx, %cx
	mov DE_OFF_NAME_SIZE(%bx), %cl

.run__name_lp:
	# (name_size == 0) ? {end}
	test %cx, %cx
	jz .run__name_end

	# cpy
	mov (%si), %al
	call putc

	inc %si
	dec %cx
	jmp .run__name_lp

.run__name_end:
	call putsp
	call putsp

.run__lp_step:
	# add rec_size
	mov DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	sub %ax, %dx # file_size--

	# (f_size <= 0) ? {done} : {lp}
	cmp $0x00, %dx
	jle .done
	jmp .run__lp

# {DONE}
.done:
	mov (write_sbuf), %ax
	test %ax, %ax
	jz 1f
	call putnl

1:
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
	mov %bp, %sp
	pop %bp
	ret

# {ERR}
.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_dir_no:
	push $emsg_dir_no
	jmp .err_hdl

.err_dir_type:
	push $emsg_dir_type
	jmp .err_hdl

.err_hdl:
	call vga_outs
	add $0x02, %sp
	NEWLINE
	jmp .exit

8001:
	mov (%di), %al # opt_chr
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
