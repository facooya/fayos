# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Lookup directory entry

.include "fayfs/de.s"
.section .text
.code16
.global lookup_dentry

# lookup_dentry(
# inum_hi, inum_lo
# name_len,
# name_ptr
# )
# <ret> ax = not_match:0, match:memory
lookup_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {{{ read block
	# read_inode(inum_hi, inum_lo)
	mov 0x06(%bp), %ax
	push %ax # inum_lo
	mov 0x04(%bp), %ax
	push %ax # inum_hi
	call read_inode
	add $0x04, %sp

	call set_blk_lba
	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	# }}}

	# {pre}
	mov 0x08(%bp), %dx # src_name_len
	mov 0x0A(%bp), %si # src_name

.lp:
	# {{{ len compare
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl # dst_name_len

	# {end.done.nm} (dst_name_len == null)
	test %cx, %cx
	jz .done__nm

	# {lp.step} (src_name_len != dst_name_len)
	cmp %cx, %dx
	jne .lp__step
	# }}}

	# {{{ str compare
	mov %bx, %di
	add $DE_NAME_OFF, %di # dst_name

	push %dx
	push %cx # dst_name_len
	push %di # dst_name
	push %si # src_name
	call strncmp
	add $0x06, %sp
	pop %dx

	# {end.done.m} (strncmp == true)
	test %ax, %ax
	jz .done__m
	# }}}

.lp__step:
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# {lp}
	jmp .lp

# {DONE}
.done__m:
	mov %bx, %ax
	jmp .epil

.done__nm:
	xor %ax, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
