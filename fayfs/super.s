# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Superblock

.include "fayfs/sb.s"
.section .data
.name_dot: .asciz "."
.name_dotdot: .asciz ".."
.sb_try_msg: .asciz "\nSuperblock not found. Try creating ...\r\n"
.sb_found_msg: .asciz "\nSuperblock found.\r\n"
.sb_ok_msg: .asciz "Superblock ok\r\n"

.section .text
.code16
.global init_super

# init_super()
init_super:
	push %si
	push %bx

	push $dap_super
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# {{{ check superblock
	# {task} (get_magic_low != magic_low)
	mov SB_MAG_LO_OFF(%bx), %ax
	cmp $SB_MAG_LO, %ax
	jne .run

	# {task} (get_magic_high != magic_high)
	mov SB_MAG_HI_OFF(%bx), %ax
	cmp $SB_MAG_HI, %ax
	jne .run

	push $.sb_found_msg
	call outs
	add $0x02, %sp

	# {end.done}
	call read_super
	jmp .done
	# }}}

# {TASK}
.run:
	push $.sb_try_msg
	call outs
	add $0x02, %sp

	# TODO: super block
	# {{{ allocate lba
	mov $0x0600, %si
	add $DP_BUF_OFF, %si
	call _sys_read_disk_param
	call ._alloc_lba
	# }}}

	call ._set_data
	push $dap_super
	call write_disk
	add $0x02, %sp

	# TODO: FST_INUM = root

	call read_super
	call ._set_dentry
	jmp .done

# {DONE}
.done:
	push $.sb_ok_msg
	call outs
	add $0x02, %sp

	pop %bx
	pop %si
	ret

# {TASK}
# ._alloc_lba()
._alloc_lba:
	# mov DP_LBA_LO_SIZE_OFF(%bx), %ax
	# mov DP_LBA_HI_SIZE_OFF(%bx), %ax
	ret

# {TASK}
# ._set_data()
._set_data:
	# magic
	mov $SB_MAG_LO, %ax
	mov %ax, SB_MAG_LO_OFF(%bx)
	mov $SB_MAG_HI, %ax
	mov %ax, SB_MAG_HI_OFF(%bx)

	# sb lba
	mov $SB_LBA, %ax
	mov %ax, SB_LBA_OFF(%bx)

	# fst lba
	mov $FST_LBA, %ax
	mov %ax, FST_LBA_OFF(%bx)

	# fst blk
	mov $FST_BLK, %ax
	mov %ax, FST_BLK_OFF(%bx)

	# fst inum
	mov $FST_INUM, %ax
	mov %ax, FST_INUM_OFF(%bx)

	# i size
	mov $I_SIZE, %ax
	mov %ax, I_SIZE_OFF(%bx)

	# next i num
	mov $NEXT_I_NUM_LO, %ax
	mov %ax, NEXT_I_NUM_LO_OFF(%bx)

	# next blk num
	mov $NEXT_I_BLK_LO, %ax
	mov %ax, NEXT_I_BLK_LO_OFF(%bx)
	ret

# {TASK}
# ._set_dentry()
._set_dentry:
	# add inode root
	mov $0x40, %ch
	mov $0x01, %cl
	push %cx
	mov FST_BLK_OFF(%bx), %ax
	push %ax
	xor %ax, %ax
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_inode
	add $0x0A, %sp

	# add dentry dot
	mov $.name_dot, %si
	mov $0x01, %cl # name len
	mov $0x40, %ch
	push %si
	push %cx
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp

	# add dentry dotdot
	mov $.name_dotdot, %si
	mov $0x02, %cl # name len
	mov $0x40, %ch
	push %si
	push %cx
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	xor %ax, %ax
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	xor %ax, %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	ret
