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
# i_num_hi, i_num_lo
# src_name_len,
# src_name
# )
# <ret> ax = not_match:0, match:memory
lookup_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {{{ read block
	# read_inode(i_num_hi, i_num_lo)
	# <ret> i_file_size, i_blk
	mov 0x06(%bp), %ax
	push %ax # i_num_lo
	mov 0x04(%bp), %ax
	push %ax # i_num_hi
	call read_inode
	add $0x04, %sp

	call set_blk_lba
	call read_block
	mov $0x8000, %bx
	# }}}

	# {pre}
	mov 0x08(%bp), %dx # src_name_len
	mov 0x0A(%bp), %si # src_name

.lp:
	# {{{ chk delete
	# {lp.step} (i_num == 0)
	mov DE_I_NUM_LO_OFF(%bx), %ax
	test %ax, %ax
	or DE_I_NUM_LO_OFF(%bx), %ax
	jz .lp__step
	# }}}

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
	# {{{ chk end
	# {end.done.nm} (rec_len == null)
	mov DE_REC_LEN_OFF(%bx), %cx
	test %cx, %cx
	jz .done__nm
	add %cx, %bx
	# }}}

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
