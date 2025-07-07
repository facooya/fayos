# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Initialization superblock

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
	push %bx

	# {{{ read super lba
	push $0x8000
	push $0x00
	push $0x02
	call set_dap_target
	add $0x06, %sp

	push $SB_LBA_LO
	push $SB_LBA_HI
	call set_dap_lba
	add $0x04, %sp

	call read_block
	mov $0x8000, %bx
	# }}}

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
	call reset_dap_target
	call read_super
	jmp .done
	# }}}

# {TASK}
.run:
	push $.sb_try_msg
	call outs
	add $0x02, %sp

	call ._set_data
	call write_block
	call reset_dap_target

	call read_super
	call ._set_dentry
	jmp .done

# {DONE}
.done:
	push $.sb_ok_msg
	call outs
	add $0x02, %sp

	pop %bx
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
	mov $SB_LBA_LO, %ax
	mov %ax, SB_LBA_LO_OFF(%bx)
	mov $SB_LBA_HI, %ax
	mov %ax, SB_LBA_HI_OFF(%bx)

	# i tbl lba
	mov $I_LBA_LO, %ax
	mov %ax, I_LBA_LO_OFF(%bx)
	mov $I_LBA_HI, %ax
	mov %ax, I_LBA_HI_OFF(%bx)

	# root i num
	mov $ROOT_I_NUM_LO, %ax
	mov %ax, ROOT_I_NUM_LO_OFF(%bx)
	mov $ROOT_I_NUM_HI, %ax
	mov %ax, ROOT_I_NUM_HI_OFF(%bx)

	# fst lba
	mov $FST_LBA_LO, %ax
	mov %ax, FST_LBA_LO_OFF(%bx)
	mov $FST_LBA_HI, %ax
	mov %ax, FST_LBA_HI_OFF(%bx)

	# fst i num
	mov $FST_I_NUM_LO, %ax
	mov %ax, FST_I_NUM_LO_OFF(%bx)
	mov $FST_I_NUM_HI, %ax
	mov %ax, FST_I_NUM_HI_OFF(%bx)

	# root i blk
	mov $ROOT_I_BLK_LO, %ax
	mov %ax, ROOT_I_BLK_LO_OFF(%bx)
	mov $ROOT_I_BLK_HI, %ax
	mov %ax, ROOT_I_BLK_HI_OFF(%bx)

	# i size
	mov $I_SIZE, %ax
	mov %ax, I_SIZE_OFF(%bx)

	# next i num
	mov $NEXT_I_NUM_LO, %ax
	mov %ax, NEXT_I_NUM_LO_OFF(%bx)
	mov $NEXT_I_NUM_HI, %ax
	mov %ax, NEXT_I_NUM_HI_OFF(%bx)

	# next blk num
	mov $NEXT_I_BLK_LO, %ax
	mov %ax, NEXT_I_BLK_LO_OFF(%bx)
	mov $NEXT_I_BLK_HI, %ax
	mov %ax, NEXT_I_BLK_HI_OFF(%bx)
	ret

# {TASK}
# ._set_dentry()
._set_dentry:
	# add inode root
	mov $0x40, %ch
	mov $0x01, %cl
	push %cx
	mov ROOT_I_BLK_LO_OFF(%bx), %ax
	push %ax
	mov ROOT_I_BLK_HI_OFF(%bx), %ax
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
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	ret
