# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Arrow key down - history

.include "fayfs/inode.s"
.include "fayfs/dentry.s"
.section .text
.code16
.global kbd_key_down

# kbd_key_down()
kbd_key_down:
	push %es
	push %di
	push %bx

	# upd hist_idx
	mov (hist_idx), %ax
	mov (file_lines), %cx
	cmp %cx, %ax
	jge .done
	inc %ax
	mov %ax, (hist_idx)

	# {{{ read root dir
	push $inode
	push $root_inum
	call read_inode
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
	call read_inode
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

	push $hist_buf
	call bufzero
	add $0x02, %sp

	push $raw_buf
	push $hist_buf
	call bufcpy
	add $0x04, %sp
	# }}}

	# {{{ clear
	push $raw_buf
	call bufzero
	add $0x02, %sp

	call vga_clr_line

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs
	# }}}

	call kbd_upd_hist
	jmp .done

.done:
	pop %bx
	pop %di
	pop %es
	ret
