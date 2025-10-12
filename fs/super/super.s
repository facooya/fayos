# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Process superblock

.include "fs/super.s"
.section .data
.kmsg_try: .asciz "\r\nSuperblock not found. Try creating ...\r\n"
.kmsg_found: .asciz "\r\nSuperblock found.\r\n"
.kmsg_ok: .asciz "Superblock ok\r\n"

.section .text
.code16
.global proc_super

# proc_super()
proc_super:
	push %es
	push %si
	push %bx

	push $0x01 # sect_cnt
	push $0x01 # lba_lo
	xor %ax, %ax
	push %ax # lba_hi
	mov $0x0600, %ax
	push %ax # off
	xor %ax, %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	# {{{ check superblock
	# {task} (disk_magic_low != magic_low)
	mov %es:S_MAG_OFF(%bx), %ax
	cmp $(S_MAG&0xFFFF), %ax
	jne .run_make

	# {task} (disk_magic_high != magic_high)
	mov %es:S_MAG_OFF+0x02(%bx), %ax
	cmp $(S_MAG>>0x10), %ax
	jne .run_make

	push $.kmsg_found
	call vga_puts
	add $0x02, %sp
	# }}}
	
	# {task}
	jmp .run_init

# {TASK}
.run_make:
	push $.kmsg_try
	call vga_puts
	add $0x02, %sp

	# {{{ write superblock disk
	mov %bx, %si
	add $DP_BUF_OFF, %si
	call ata_get_sect
	mov %ax, 0x10(%si) # HACK
	mov %dx, 0x12(%si) # HACK

	call _super_alloc_lba
	call _super_write_data

	push $0x01 # sect_cnt
	push $0x01 # lba_lo
	xor %ax, %ax
	push %ax # lba_hi
	mov $0x0600, %ax
	push %ax # off
	xor %ax, %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp
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
	push $.kmsg_ok
	call vga_puts
	add $0x02, %sp

	pop %bx
	pop %si
	pop %es
	ret
