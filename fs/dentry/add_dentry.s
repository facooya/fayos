# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Add directory entry

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global add_dentry

# add_dentry(
# *src_inum,
# *dst_inum,
# info,
# *name
# )
# <req> info = file_type:name_len
add_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

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

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	add %ax, %bx # set mem

	# {task}
	jmp .write

# {TASK}
.write:
	# write inum
	mov 0x06(%bp), %si
	mov (%si), %ax # dst_lo
	mov %ax, DE_INUM_OFF(%bx)
	mov 0x02(%si), %ax # dst_hi
	mov %ax, DE_INUM_OFF+0x02(%bx)

	# write info
	mov 0x08(%bp), %dx # dh:dl = file_type:name_len
	mov %dh, DE_FILE_TYPE_OFF(%bx)
	mov %dl, DE_NAME_LEN_OFF(%bx)

	# write rec_size
	xor %cx, %cx
	mov %dl, %cl
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, DE_REC_LEN_OFF(%bx)
	push %cx

	# dst name
	mov %bx, %di
	add $DE_NAME_OFF, %di

	mov 0x0A(%bp), %si # name
	xor %cx, %cx
	mov %dl, %cl # name_len

.write__name_lp:
	# {end} (name_len == 0)
	test %cl, %cl
	jz .write__end

	# cpy
	mov (%si), %al
	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cl
	jmp .write__name_lp

.write__end:
	# write blk
	push $dap
	call write_disk
	add $0x02, %sp

	xor %ax, %ax
	mov %ax, %ds

	# {end.done}
	pop %ax # rec_len
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
