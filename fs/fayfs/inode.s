# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Index node

.include "fayfs/sb.s"
.include "fayfs/i.s"

.section .text
.code16
.global set_i_lba
.global get_i_blk
.global add_inode
.global update_i_file_size
.global read_inode

# ENTRY
# [n_add_inode]
# add_inode(
# i_num_hi, i_num_lo
# i_blk_num_hi, i_blk_num_lo
# info (hi=file_type, lo=blk_len),
# # FIXME!!! blk_arr, blk_len
# )
add_inode:
	# prol
	push %bp
	mov %sp, %bp
	push %bx

	# read i tbl
	call set_i_lba
	call read_block
	mov $0x8000, %bx

	# calc inode # FIXME!!! hi,lo
	xor %dx, %dx
	mov 0x06(%bp), %cx
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	# set mem
	add %ax, %bx

	# write i_blk # FIXME!!! hi,lo
	mov 0x0A(%bp), %ax
	mov %ax, I_BLK_LO_OFF(%bx)

	# write info
	mov 0x0C(%bp), %ax
	mov %ah, I_FILE_TYPE_OFF(%bx)
	mov %al, I_BLK_LEN_OFF(%bx)

	# write
	call write_block

	# epil
	pop %bx
	pop %bp
	ret

# ENTRY
# update_i_file_size(i_num_hi, i_num_lo, i_file_size)
update_i_file_size:
	# prol
	push %bp
	mov %sp, %bp
	push %bx

	# read i tbl
	call set_i_lba
	call read_block
	mov $0x8000, %bx

	# calc inode # HACK!!!: only low
	xor %dx, %dx
	mov 0x06(%bp), %cx
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	# set mem
	add %ax, %bx

	# update file_size
	mov 0x08(%bp), %ax
	mov %ax, I_FILE_SIZE_OFF(%bx)

	# write
	call write_block

	# epil
	pop %bx
	pop %bp
	ret

# ENTRY
# get_i_blk(i_num_hi, i_num_lo)
# ret: i_blk
get_i_blk:
	# prol
	push %bp
	mov %sp, %bp
	push %bx

	# read inode
	call set_i_lba
	call read_block
	mov $0x8000, %bx

	# calc i_num
	xor %dx, %dx
	mov 0x06(%bp), %cx
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	# set mem
	add %ax, %bx

	# set i_blk
	mov I_BLK_LO_OFF(%bx), %ax
	mov %ax, (i_blk) # TMP
	mov I_BLK_HI_OFF(%bx), %dx
	mov %dx, (i_blk+0x02) # TMP

	# epil
	pop %bx
	pop %bp
	ret

# ENTRY
# read_inode(i_num_hi, i_num_lo)
# ret: i_blk
# ret: i_file_size
read_inode:
	# prol
	push %bp
	mov %sp, %bp
	push %bx

	# read inode
	call set_i_lba
	call read_block
	mov $0x8000, %bx

	# calc i_num
	xor %dx, %dx
	mov 0x06(%bp), %cx
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	# set mem
	add %ax, %bx

	# set i_file_size
	mov I_FILE_SIZE_OFF(%bx), %ax
	mov %ax, (i_file_size)

	# set i_blk
	mov I_BLK_LO_OFF(%bx), %ax
	mov %ax, (i_blk) # TMP
	mov I_BLK_HI_OFF(%bx), %dx
	mov %dx, (i_blk+0x02) # TMP

	# epil
	pop %bx
	pop %bp
	ret

# ENTRY
# set_i_lba()
set_i_lba:
	# set lba
	push $I_LBA_LO
	push $I_LBA_HI
	call set_dap_lba
	add $0x04, %sp
	ret
