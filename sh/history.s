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
# <req: cl_sbuf, file_line_cv>
# <mod: cl_hist_sbuf, hist_idx, fsp {base, tmp}>
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
	# (path_parse() != done) ? {done} : {save}
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

	# { fparse history
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push $fsp+FSP_OFF_TMP # (fsp &src)
	push %bx
	push %es
	call file_parse_lines
	add $0x06, %sp

	# upd hist_idx
	mov (file_line_cv), %ax
	mov %ax, (hist_idx)

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
	# }

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# hist_upd_cl()
# <req: ps1, hist_idx, file_line_cv>
# <mod: cl_sbuf, curs, fsp {root, tmp}>
# <ret: ax = cl_pos>
hist_upd_cl:
	push %es
	push %si
	push %di
	push %bx

	mov $fsp+FSP_OFF_ROOT, %si
	push FSP_OFF_INUM(%si) # (inum)
	push $fsp+FSP_OFF_ROOT # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	push $fsp+FSP_OFF_ROOT
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $_name_hist # (&name)
	push $fsp+FSP_OFF_ROOT # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}

	# (de_seek == false) ? {done}
	cmp $0x01, %ax
	je 90f
	add %ax, %bx

	# { read history file
	mov %es:DE_OFF_INUM(%bx), %ax
	push %ax # (inum)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx
	# }

	# { fparse
	push $fsp+FSP_OFF_TMP
	push %bx
	push %es
	call file_parse_lines
	add $0x06, %sp
	# }

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

	mov $file_line_cv, %si
	add $0x02, %si
	mov (hist_idx), %ax
	add %ax, %si
	add %ax, %si
	mov (%si), %dx # line_v
	add %dx, %bx # hist_file

	xor %ax, %ax
	mov $CHR_CR, %al
	push %ax # (val)
	push %bx # (off)
	push %es # (seg)
	call mem_size_val
	add $0x06, %sp
	# <ret: ax = size>
	mov %ax, %cx

	mov $cl_sbuf, %di
	mov %cx, (%di)
	add $0x02, %di

1:
	# (size == 0) ? {end}
	test %cx, %cx
	jz 9f

	mov %es:(%bx), %al
	mov %al, (%di)

	inc %di
	inc %bx
	dec %cx
	jmp 1b

9:
	# { upd disp
	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:size]
	push %si
	push %cx
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

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
.global hist_idx
hist_idx: .word 0x00
_fpath_hist: .asciz "/.history"
_name_hist: .asciz ".history"
