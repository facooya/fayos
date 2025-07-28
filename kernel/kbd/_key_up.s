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

# _key_up()
# <req> *si = raw_buf
# <ret> raw_buf
_key_up:
	push %bx
	push %di

	mov $de_hist, %di
	xor %cx, %cx
	mov (%di), %ax
	mov %al, %cl
	add $0x02, %di
	push %di
	push %cx
	push $root_inum
	call lookup_dentry
	add $0x06, %sp
	mov %ax, %bx

	# {end.done} (lookup_dentry == no_match)
	test %ax, %ax
	jz .done

	mov DE_INUM_OFF(%bx), %ax
	mov %ax, (tmp_inum)
	mov DE_INUM_OFF+0x02(%bx), %ax
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

.clear:
	push %bx # [s.1] mem

	# update cursor
	call _sys_get_cursor
	mov (cursor+0x01), %dl
	call _sys_set_cursor

	mov $raw_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip buf.len
	add %cx, %si # last buf.data

.clear__lp:
	# {end} (buf.len == 0)
	test %cx, %cx
	jz .clear__end

	push %cx # [s.2] buf.len
	call _sys_get_cursor
	sub $0x01, %dl # cursor.x
	call _sys_set_cursor

	call outsp
	call _sys_set_cursor
	pop %cx # [s.2] buf.len

	xor %al, %al
	mov %al, (%si)

	sub $0x01, %si
	sub $0x01, %cx
	jmp .clear__lp

.clear__end:
	# zero len
	xor %ax, %ax
	mov %ax, (raw_buf)

	pop %bx # [s.1] mem

	push $inode
	push %bx
	call parse_file_lines
	add $0x04, %sp

.raw:
	mov $raw_buf, %si
	add $0x02, %si # skip buf.len
	xor %cx, %cx # size

.raw__lp:
	# {end} (hist == cr)
	mov (%bx), %al
	cmp $CHR_CR, %al
	je .raw__end

	mov %al, (%si)

	add $0x01, %si # buf.data
	add $0x01, %bx # mem
	add $0x01, %cx # size
	jmp .raw__lp

.raw__end:
	mov $raw_buf, %si
	mov %cx, (%si) # save buf.len

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

.done:
	pop %bx
	pop %di
	ret
