# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.s"
.include "fs/fs.s"
.include "drv/disk.s"
.include "fs/de.s"
.include "fs/ind.s"
.section .text
.code16
.global history
.global hist_upd_cl

# [public] history()
# <req> cl_sbuf, file_lines
# <mod> cl_hist_sbuf, hist_idx, fsp {base, tmp}
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
	xor %ax, %ax
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_BASE # (&s_off)
	push %ax # (&s_seg)
	push $fsp+FSP_OFF_TMP # (&d_off)
	push %ax # (&d_seg)
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
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %ax, %bx

	mov $cl_sbuf, %si
	mov (%si), %cx # buf.size
	push %cx # [s.4] buf.size
	add $0x02, %si # skip size

1: # append
	mov (%si), %al

	# (size == 0) ? {end}
	test %cx, %cx
	jz 9f

	mov %al, %es:(%bx)

	inc %si # buf.data
	inc %bx # mem
	dec %cx # buf.size
	jmp 1b

9:
	pop %cx # [s.4] buf.size
	mov $CHR_CR, %al
	mov %al, %es:(%bx)
	mov $CHR_LF, %al
	mov %al, %es:0x01(%bx)
	add $0x02, %bx # mem
	add $0x02, %cx # his.size

	push %cx
	push $fsp+FSP_OFF_TMP
	call disk_write_fsp
	add $0x02, %sp
	pop %cx

	# { update .history size
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)
	push %si
	call fsp_write
	add $0x02, %sp
	# }

	# { fparse history
	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push $fsp+FSP_OFF_TMP
	push %bx
	push %es
	call fparse_lines
	add $0x06, %sp

	# upd hist_idx
	mov (file_lines), %ax
	mov %ax, (hist_idx)

	# zero
	xor %ax, %ax
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp
	# }

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# [public] hist_upd_cl()
# <req> ps1, hist_idx, file_lines, file_linev
# <mod> cl_sbuf, curs, fsp {root, tmp}
# <ret> ax = cl_pos
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
	call fparse_lines
	add $0x06, %sp
	# }

	# { clear
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	call vga_clr_line

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs
	# }

	mov $file_lines, %di
	mov (%di), %cx # linec
	add $0x02, %di
	mov (hist_idx), %ax
	add %ax, %di
	add %ax, %di
	mov (%di), %dx # line_size

	mov $cl_sbuf, %si
	mov %dx, (%si)
	add $0x02, %si

	mov (hist_idx), %ax
	mov $file_linev, %di
	add %ax, %di
	add %ax, %di
	mov (%di), %dx # tgt_line
	add %dx, %bx # hist_file
	mov (cl_sbuf), %cx

1:
	# (size == 0) ? {end}
	test %cx, %cx
	jz 9f

	mov %es:(%bx), %al
	mov %al, (%si)

	inc %si
	inc %bx
	dec %cx
	jmp 1b

9:
	# { upd disp
	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:len]
	push %si
	push %cx
	call vga_putls
	add $0x04, %sp
	pop %cx # [s.f0:len]
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

# [data]
.section .data
.global hist_idx
hist_idx: .word 0x00
_fpath_hist: .asciz "/.history"
_name_hist: .asciz ".history"
