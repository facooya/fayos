# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key arrow up - history

# HACK
.include "chr.s"
.include "fayfs/dentry.s"
.section .data
.history: .asciz ".history"
.root_inum: .long 0x01
.hist_inum: .long 0x00

.section .text
.code16
.global _key_up

# _key_up()
# <req> *si = raw_buf
# <ret> raw_buf
_key_up:
	push %bx

	push $.history
	call strlen
	add $0x02, %sp

	push $.history
	push %ax
	push $.root_inum
	call lookup_dentry
	add $0x06, %sp
	mov %ax, %bx

	# {end.done} (lookup_dentry == no_match)
	test %ax, %ax
	jz .done

	mov DE_INUM_OFF(%bx), %ax
	mov %ax, (.hist_inum)
	mov DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (.hist_inum+0x02)

	push $inode
	push $.hist_inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

.raw:
	# *si = raw_buf
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
	mov %cx, (raw_buf) # save buf.len

.done:
	pop %bx
	ret
