# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Process superblock

.include "fayfs/super.s"
.section .data
.kmsg_try: .asciz "\nSuperblock not found. Try creating ...\r\n"
.kmsg_found: .asciz "\nSuperblock found.\r\n"
.kmsg_ok: .asciz "Superblock ok\r\n"

.section .text
.code16
.global proc_super

# proc_super()
proc_super:
	push %si
	push %bx

	push $dap_super
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds

	# {{{ check superblock
	# {task} (disk_magic_low != magic_low)
	mov S_MAG_OFF(%bx), %ax
	cmp $(S_MAG&0xFFFF), %ax
	jne .run_make

	# {task} (disk_magic_high != magic_high)
	mov S_MAG_OFF+0x02(%bx), %ax
	cmp $(S_MAG>>0x10), %ax
	jne .run_make

	push $.kmsg_found
	call outs
	add $0x02, %sp
	# }}}
	
	# {task}
	jmp .run_init

# {TASK}
.run_make:
	push $.kmsg_try
	call outs
	add $0x02, %sp

	# {{{ write superblock disk
	mov %bx, %si
	add $DP_BUF_OFF, %si
	call _sys_read_disk_param

	call _super_alloc_lba
	call _super_write_data

	push $dap_super
	call write_disk
	add $0x02, %sp
	# }}}

	call _super_set_lba
	call _super_set_bitmap

	mov $(ROOT_INUM&0xFFFF), %ax
	mov %ax, (root_inum)
	mov %ax, (inum)
	mov $(ROOT_INUM>>0x10), %ax
	mov %ax, (root_inum+0x02)
	mov %ax, (inum+0x02)
	call _super_make_root

	jmp .done

# {TASK}
.run_init:
	mov $(ROOT_INUM&0xFFFF), %ax
	mov %ax, (root_inum)
	mov %ax, (inum)
	mov $(ROOT_INUM>>0x10), %ax
	mov %ax, (root_inum+0x02)
	mov %ax, (inum+0x02)

	call _super_set_lba

	jmp .done

# {DONE}
.done:
	xor %ax, %ax
	mov %ax, %ds

	push $.kmsg_ok
	call outs
	add $0x02, %sp

	pop %bx
	pop %si
	ret
