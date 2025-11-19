# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Histroy] Update command line

.include "fs/fs.s"
.include "fs/de.s"
.section .data
.name_hist: .asciz ".history"
.section .text
.code16
.global hist_upd_cl

# hist_upd_cl()
# <req> hist_idx, file_lines
# <mod> cl_sbuf, curs
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

	push $.name_hist # (&name)
	push $fsp+FSP_OFF_ROOT # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}

	# (de_seek == false) ? {done}
	cmp $0x01, %ax
	je .done
	add %ax, %bx

	# {{{ read history file
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

	# {{{ fparse
	push $fsp+FSP_OFF_TMP
	push %bx
	push %es
	call fparse_lines
	add $0x06, %sp
	# }}}

	# {{{ clear
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
	# }}}

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

.lp:
	# (len == 0) ? {end}
	test %cx, %cx
	jz .end

	mov %es:(%bx), %al
	mov %al, (%si)

	inc %si
	inc %bx
	dec %cx
	jmp .lp

.end:
	# {{{ upd disp
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
	# }}}

.done:
	mov %si, %ax # <ret:cl_pos>

	pop %bx
	pop %di
	pop %si
	pop %es
	ret
