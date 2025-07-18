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
# src_inum_hi, src_inum_lo,
# dst_inum_hi, dst_inum_lo,
# info (file_type:name_len),
# name_ptr
# )
add_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	mov $inode, %si
	push %si
	mov 0x06(%bp), %ax # src_lo
	push %ax
	mov 0x04(%bp), %ax # src_hi
	push %ax
	call read_inode
	add $0x06, %sp

	mov I_BLK_0_LO_OFF(%si), %ax
	push %ax
	mov I_BLK_0_HI_OFF(%si), %ax
	push %ax
	call set_dap_blk_lba
	add $0x04, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# {task}
	jmp .alloc

# {TASK}
.alloc:
.alloc__lp:
	# {end} (rec_len == null)
	mov DE_REC_LEN_OFF(%bx), %ax
	test %ax, %ax
	jz .alloc__end

	# {lp}
	add %ax, %bx
	jmp .alloc__lp

.alloc__end:
	# {task}
	jmp .write

# {TASK}
.write:
	# write inum
	mov 0x08(%bp), %ax # dst_hi
	mov %ax, DE_INUM_HI_OFF(%bx)
	mov 0x0A(%bp), %ax # dst_lo
	mov %ax, DE_INUM_LO_OFF(%bx)

	# write info
	mov 0x0C(%bp), %dx # dh:dl = file_type:name_len
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

	mov 0x0E(%bp), %si # name
	xor %cx, %cx
	mov %dl, %cl # name_len

.write__name_lp:
	# {end} (name_len == null)
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
