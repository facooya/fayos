# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make root

.section .text
.code16
.global _super_make_root

# _super_make_root()
_super_make_root:
	# add inode root
	mov $0x40, %ch
	mov $0x01, %cl
	push %cx

	# {{{ alloc blknum bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	xor %ax, %ax
	push %ax
	# }}}

	# {{{ alloc inum bit
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp
	mov %ax, (inum)
	push %ax
	xor %ax, %ax
	push %ax
	# }}}
	call add_inode
	add $0x0A, %sp

	# {{{ set inum bit
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	mov (inum), %ax
	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp
	# }}}

	# {{{ set blknum bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_bb
	call write_disk
	add $0x02, %sp
	# }}}

	# add dentry dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
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
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
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
