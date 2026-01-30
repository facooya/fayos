# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "drv/disk.inc"
.include "fs/de.inc"
.include "fs/ind.inc"
.section .text
.code16
.global history
.global hist_upd_cl

# history()
# <req: cl_sbuf>
# <mod: cl_hist_sbuf, hist_idx, hist_cv, fsp {base, tmp}>
history:
	push %es
	push %si
	push %di
	push %bx

	# { path
	push $_fpath_hist # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == neq_last) ? {create}
	cmp $0x02, %ax
	je 10f # create
	# (path_parse() != done) ? {exit}
	test %ax, %ax
	jnz 99f
	# }

	# cpy base -> tmp
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_BASE # (s_off)
	push %ds # (s_seg)
	push $fsp+FSP_OFF_TMP # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	jmp 20f # save

10: # create
	push $F_TYPE_FILE # (f_type)
	push $_fpath_hist # (&name)
	call fs_add
	add $0x04, %sp
	# <mod: fsp *tmp>
	jmp 20f # save

20: # save
	mov $cl_sbuf, %si
	mov (%si), %ax
	add $0x02, %si

	push %ax # [s.f0: buf_size]
	push %ax # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	push $fs_write_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	pop %ax # [s.f0: buf_size]

	push %ax # [s.0: buf_size]
	mov $fs_write_buf, %si
	add %ax, %si
	mov $CHR_CR, %al
	mov %al, (%si)
	mov $CHR_LF, %al
	mov %al, 0x01(%si)

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %cx

	pop %ax # [s.0: buf_size]
	add $0x02, %ax
	push %ax # (size)
	push %cx # (idx)
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call fs_write
	add $0x06, %sp

	# upd cnt
	mov (hist_cv), %ax
	inc %ax
	mov %ax, (hist_cv)
	mov %ax, (hist_idx)

	# { upd hist_cv
	xor %ax, %ax
	mov $CHR_LF, %al
	push %ax
	push $fs_write_buf # (off)
	push %ds # (seg)
	call mem_size_val
	add $0x06, %sp
	# <ax = size>
	inc %ax

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %dx
	sub %ax, %dx

	mov $hist_cv, %di
	mov (%di), %cx
	add %cx, %di
	add %cx, %di
	mov %dx, (%di)
	# }

	# zero
	xor %ax, %ax
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_sbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# hist_upd_cl()
# <req: ps1, hist_idx, hist_cv>
# <mod: cl_sbuf, curs, fsp {root, tmp}>
# <ret: ax = cl_pos>
hist_upd_cl:
	push %es
	push %si
	push %di
	push %bx

	# { clear
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp

	call vga_clr_line

	push $ps1
	call vga_outs
	add $0x02, %sp

	call vga_init_curs
	# }

	# { file -> buf
	push $_fpath_hist # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() != 0) ? {exit}
	test %ax, %ax
	jnz 99f

	# cpy base -> tmp
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_BASE # (s_off)
	push %ds # (s_seg)
	push $fsp+FSP_OFF_TMP # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# calc file off
	mov $hist_cv, %si
	add $0x02, %si
	mov (hist_idx), %ax
	add %ax, %si
	add %ax, %si
	mov (%si), %dx # line_v
	add %dx, %bx

	# get str size
	push %dx # [s.f0: line_v]
	xor %ax, %ax
	mov $CHR_CR, %al
	push %ax # (val)
	push %bx # (off)
	push %es # (seg)
	call mem_size_val
	add $0x06, %sp
	# <ret: ax = size>
	pop %dx # [s.f0: line_v]

	push %ax # [s.f0: size]
	push %ax # (size)
	push %dx # (idx)
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call fs_read
	add $0x06, %sp
	pop %ax # [s.f0: size]

	mov $cl_sbuf, %di
	mov %ax, (%di)
	add $0x02, %di

	push %ax # (size)
	push $fs_read_buf # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	# }

	# { upd disp
	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:size]
	push %si # (&str)
	push %cx # (num)
	call vga_outns
	add $0x04, %sp
	pop %cx # [s.f0:size]
	add %cx, %si

	mov (curs), %ax
	add %ax, %cx
	mov %cx, (curs+0x02)
	# }

90:
	mov %si, %ax # <ret:cl_pos>

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
.global hist_idx
.global hist_cv
hist_idx: .word 0x00
hist_cv: .zero 0x100
_fpath_hist: .asciz "/.history"
_name_hist: .asciz ".history"
