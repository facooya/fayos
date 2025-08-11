# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key arrow down - history

.include "chr.s"
.include "fayfs/inode.s"
.include "fayfs/dentry.s"
.section .text
.code16
.global _key_down

# _key_down
# <req> *si = raw_buf
# <ret> raw_buf
_key_down:
	push %es
	push %di
	push %bx

	# {{{ hist data
	mov (hist_data), %ax
	test %ax, %ax
	jz .done__pass

	cmp $0x02, %ax
	je .hist_stack_pass

	mov (hist_stack), %ax
	sub $0x02, %ax
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

	# {{{
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

	# {{{ read file
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

	call _kbd_hist_line

	mov $0x02, %ax
	mov %ax, (hist_data)

	mov (hist_stack), %ax
	test %ax, %ax
	jz .done

	sub $0x01, %ax
	mov %ax, (hist_stack)
	jmp .done

.done__pass:
	jmp .epil

.done:
.epil:
	pop %bx
	pop %di
	pop %es
	ret
