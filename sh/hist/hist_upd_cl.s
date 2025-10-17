# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Histroy] Update command line

.include "fs/inode.s"
.include "fs/dentry.s"
.section .text
.code16
.global hist_upd_cl

# hist_upd_cl()
# <req> hist_idx
# <req> file_lines
# <ret> cl_lbuf
# <ret> curs
# <ret> si
hist_upd_cl:
	push %es
	push %di
	push %bx

	# {{{ read root dir
	push $inode
	push $root_inum
	call ind_read
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es
	# }}}

	# {{{ lookup history
	mov $de_hist, %di
	xor %cx, %cx
	mov (%di), %ax
	mov %al, %cl
	add $0x02, %di
	push %di
	push %cx
	mov $inode, %di
	mov I_FILE_SIZE_OFF(%di), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp

	# {end.done.pass} (lookup_dentry() == no_match)
	cmp $0x01, %ax
	je .done

	add %ax, %bx
	# }}}

	# {{{ read history file
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (tmp_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (tmp_inum+0x02)

	push $inode
	push $tmp_inum
	call ind_read
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es
	# }}}

	# {{{ fparse
	push $inode
	push %bx
	push %es
	call fparse_lines
	add $0x06, %sp
	# }}}

	# {{{ clear
	push $cl_lbuf
	call bufzero
	add $0x02, %sp

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

	mov $cl_lbuf, %si
	mov %dx, (%si)
	add $0x02, %si

	mov (hist_idx), %ax
	mov $file_linev, %di
	add %ax, %di
	add %ax, %di
	mov (%di), %dx # tgt_line
	add %dx, %bx # hist_file
	mov (cl_lbuf), %cx

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
	mov $cl_lbuf, %si
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
	pop %bx
	pop %di
	pop %es
	ret
