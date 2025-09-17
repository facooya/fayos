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
	# {end} (hd == cr)
	mov (hist_data), %ax
	test %ax, %ax
	jz .done__pass

	# {skip} (hd == down)
	cmp $0x0200, %ax
	je .hist_stack_pass

	# {set} (hd == last_flag)
	cmp $0x0202, %ax
	je .set_hist_buf

	# {done} (hd == hist_buf)
	cmp $0x0203, %ax
	je .done

	cmp $0x0101, %ax
	je .key_mid_up

	cmp $0x0103, %ax
	je .set_hist_buf_up

	cmp $0x01, %ah
	je .key_up

	jmp .hist_stack_pass

.key_up:
	mov (hist_stack), %ax
	sub $0x01, %ax
	mov %ax, (hist_stack)
	jmp .hist_stack_pass

.key_mid_up:
	mov (hist_stack), %ax
	sub $0x02, %ax

	cmp $0x00, %ax
	jl .key_mid_up_zero

	mov %ax, (hist_stack)
	jmp .hist_stack_pass

.key_mid_up_zero:
	xor %ax, %ax
	mov %ax, (hist_stack)
	jmp .hist_stack_pass

.set_hist_buf_up:
	xor %ax, %ax
	mov %ax, (hist_stack)
	jmp .set_hist_buf

.set_hist_buf:
	push $raw_buf
	call bufzero
	add $0x02, %sp

	push $hist_buf
	push $raw_buf
	call bufcpy
	add $0x04, %sp

	call vga_clr_line

	push $ps1
	call vga_puts
	add $0x02, %sp

	call init_cursor2

.disp:
	mov $raw_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	push %cx
	mov (cursor), %ax # cursor.min
	add %ax, %cx
	mov %cx, (cursor+0x02) # update cursor.max
	pop %cx

.disp__lp:
	# {end} (buf.len == 0)
	mov (%si), %al
	test %cx, %cx
	jz .disp__end

	call vga_putc

	add $0x01, %si
	sub $0x01, %cx
	jmp .disp__lp

.disp__end:
	mov (hist_data), %ax
	mov $0x02, %ah
	mov $0x03, %al
	mov %ax, (hist_data)
	jmp .done

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

	call vga_clr_line

	push $ps1
	call vga_puts
	add $0x02, %sp

	call init_cursor2
	# }}}

	call _kbd_hist_line

	# {{{ last
	xor %ax, %ax
	mov $0x02, %ah
	mov %ax, (hist_data)

	# {done.last} (hs == 0)
	mov (hist_stack), %ax
	test %ax, %ax
	jz .done__last

	sub $0x01, %ax
	mov %ax, (hist_stack)
	# }}}

	# mid
	mov (hist_data), %ax
	mov $0x01, %al
	mov %ax, (hist_data)

	jmp .done

.done__pass:
	jmp .epil

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
	ret
