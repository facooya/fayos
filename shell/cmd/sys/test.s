# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.include "fayfs/inode.s"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si
	push %di
	push %bx

	push $inode
	push $root_inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %si
	mov 0x08(%si), %ax
	push %ax
	mov 0x0A(%si), %ax
	push %ax
	push $dap_es
	call set_src_dap_lba
	add $0x06, %sp

	call set_dap_mem

	push %es # s.1
	push $dap_es
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	mov $inode, %di
	mov I_FILE_SIZE_OFF(%di), %ax
	add %ax, %bx

	mov $'F', %al
	mov %al, %es:(%bx)
	mov $'A', %al
	mov %al, %es:0x01(%bx)

	push $dap_es
	call write_disk
	add $0x02, %sp
	pop %es # s.1

	pop %bx
	pop %di
	pop %si
	ret
