# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Lookup directory entry

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global lookup_dentry

# lookup_dentry(
# *inum
# name_len,
# *name
# )
# <ret> ax = not_match:0, match:memory
lookup_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {{{ read block
	push $inode
	push 0x04(%bp)
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds
	push %ax # offset
	# }}}

	# {pre}
	mov 0x06(%bp), %dx # name_len
	mov 0x08(%bp), %si # *name

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

	# {lp.step} (inum == 0)
	mov DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or DE_INUM_OFF+0x02(%bx), %ax
	jz .lp__step
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
	mov $inode, %di
	mov I_FILE_SIZE_OFF(%di), %ax

	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx
	mov %bx, %cx

	mov 0x0A(%bp), %ax # offset
	sub %ax, %cx

	# {end.done.nm} (cpy_mem >= file_size)
	cmp %ax, %cx
	jge .done__nm

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
	add $0x02, %sp # offset
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
