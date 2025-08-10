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
	mov (hist_data), %ax
	cmp $0x02, %ax
	jne .hist_stack_pass

	mov (hist_stack), %ax
	add $0x02, %ax
	mov %ax, (hist_stack)

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

	push $dap
	call read_disk
	add $0x02, %sp
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

	push $dap
	call read_disk
	add $0x02, %sp
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

._fparse_lines__end:
	mov $file_lines, %di
	mov (%di), %cx # lines_c
	mov (hist_stack), %ax
	sub %ax, %cx # target_line

	# {err.done.pass} (target_line <= 0)
	cmp $0x00, %cx
	jle .done__pass
	# }}}

	# {{{ clear
	push $raw_buf
	call bufzero
	add $0x02, %sp

	call clear_line_disp

	push $kernel_prompt
	call outs
	add $0x02, %sp

	call init_cursor
	# }}}

	call hist_line
	mov %ax, %bx

.raw:
	mov $raw_buf, %si
	mov %dx, (%si) # hist_line_size
	add $0x02, %si # skip buf.len

.raw__lp:
	# {end} (size == 0)
	test %dx, %dx
	jz .raw__end

	mov %es:(%bx), %al
	mov %al, (%si)

	# {lp}
	add $0x01, %si # buf.data
	add $0x01, %bx # mem
	sub $0x01, %dx # size
	jmp .raw__lp

.raw__end:

# out display
.disp:
	mov $raw_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	push %cx
	mov (cursor), %al # cursor.min
	add %al, %cl
	mov %cl, (cursor+0x01) # update cursor.max
	pop %cx

.disp__lp:
	# {end} (buf.len == 0)
	mov (%si), %al
	test %cx, %cx
	jz .disp__end

	call outc

	add $0x01, %si
	sub $0x01, %cx
	jmp .disp__lp

.disp__end:
	mov $0x01, %ax
	mov %ax, (hist_data)

	mov (hist_stack), %ax
	mov $file_lines, %si
	mov (%si), %cx
	cmp %ax, %cx
	je .done

	add $0x01, %ax
	mov %ax, (hist_stack)

	jmp .done

.done__pass:
	jmp .epil

.done:
.epil:
	pop %bx
	pop %di
	pop %es
	ret # return kbd_main()
