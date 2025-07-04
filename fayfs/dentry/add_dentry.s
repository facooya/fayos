# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Add directory entry

.include "fayfs/sb.s"
.include "fayfs/de.s"
.section .text
.code16
.global add_dentry

# add_dentry(
# src_i_num_hi, src_i_num_lo,
# dst_i_num_hi, dst_i_num_lo,
# info (file_type:name_len),
# name_ptr
# )
add_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# get blk
	mov 0x06(%bp), %ax # src_lo
	push %ax
	mov 0x04(%bp), %ax # src_hi
	push %ax
	call read_inode
	add $0x04, %sp

	# read blk
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

	# alloc_dentry()
	# <req> bx = main mem
	# <ret> ax = dentry end mem
	call alloc_dentry
	mov %ax, %bx

	# write i_num
	mov 0x08(%bp), %ax # dst_hi
	mov %ax, DE_I_NUM_HI_OFF(%bx)
	mov 0x0A(%bp), %ax # dst_lo
	mov %ax, DE_I_NUM_LO_OFF(%bx)

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

	# dst name
	mov %bx, %di
	add $DE_NAME_OFF, %di

	mov 0x0E(%bp), %si # name
	xor %cx, %cx
	mov %dl, %cl # name_len

.lp:
	# {end} (name_len == null)
	test %cl, %cl
	jz .end

	# cpy
	mov (%si), %al
	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cl
	jmp .lp

.end:
	# write blk
	call write_block

	# {call} (file_type == dir)
	cmp $0x40, %dh
	jz .call_update_i_file_size

	# {end.done}
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret

# {CALL}
.call_update_i_file_size:
	# update_i_file_size()
	mov $I_SIZE, %ax
	push %ax # dir_size
	mov 0x0A(%bp), %ax
	push %ax # i_num_lo
	mov 0x08(%bp), %ax
	push %ax # i_num_hi
	call update_i_file_size
	add $0x06, %sp

	# {end.done}
	jmp .done
