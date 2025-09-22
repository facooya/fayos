# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key arrow up - history

.include "chr.s"
.include "fayfs/inode.s"
.include "fayfs/dentry.s"
.section .text
.code16
.global _key_up

# _key_up
# <req> *si = raw_buf
# <ret> raw_buf
_key_up:
	push %es
	push %di
	push %bx

	# {{{ hist data
	# {skip} (hd == up)
	mov (hist_data), %ax
	cmp $0x01, %ah
	je .hist_stack_pass

	# { key down
	cmp $0x0201, %ax
	je .key_mid_down

	# hist_buf
	cmp $0x0203, %ax
	je .hist_stack_pass

	cmp $0x0200, %ax
	je .key_down

	cmp $0x0202, %ax
	je .key_down

	jmp .hist_stack_pass

.key_down:
	mov (hist_stack), %ax
	add $0x01, %ax
	mov %ax, (hist_stack)
	jmp .hist_stack_pass

.key_mid_down:
	mov (hist_stack), %ax
	add $0x02, %ax
	mov %ax, (hist_stack)
	jmp .hist_stack_pass
	# }

.hist_stack_pass:
	# }}}

	# {{{
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
	je .done__pass

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
	# (hist_data == 0)
	mov (hist_data), %ax
	test %ax, %ax
	jz ._fparse_lines
	jmp ._fparse_lines__end

._fparse_lines:
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

._fparse_lines__end:
	mov $file_lines, %di
	mov (%di), %cx # lines_c
	mov (hist_stack), %ax
	sub %ax, %cx # target_line

	# {err.done.pass} (target_line <= 0)
	cmp $0x00, %cx
	jle .done__over_line
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

	call _kbd_hist_line

	# {{{ last
	xor %ax, %ax
	mov $0x01, %ah
	mov %ax, (hist_data)

	# {done.last} (hs == (flc-1))
	mov (hist_stack), %ax
	mov $file_lines, %di
	mov (%di), %cx # flc
	sub $0x01, %cx
	cmp %ax, %cx
	je .done__last

	add $0x01, %ax
	mov %ax, (hist_stack)
	# }}}

	cmp $0x01, %ax
	je .fst_hist_buf

	# mid
	mov (hist_data), %ax
	mov $0x01, %al
	mov %ax, (hist_data)
	jmp .done

.fst_hist_buf:
	mov (hist_data), %ax
	mov $0x03, %al
	mov %ax, (hist_data)
	jmp .done

.done__over_line:
	xor %ax, %ax
	mov $0x01, %ah
	mov %ax, (hist_data)
	jmp .epil

.done__pass:

.done__last:
	mov (hist_data), %ax
	mov $0x02, %al
	mov %ax, (hist_data)
	jmp .epil

.done:
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %es
	ret # return kbd_main()
