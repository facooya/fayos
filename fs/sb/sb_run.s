# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Run

.include "fs/fs.s"
.include "fs/sb.s"
.include "drv/disk.s"
.section .data
.kmsg_try: .asciz "\r\nSuperblock not found. Try creating ...\r\n"
.kmsg_found: .asciz "\r\nSuperblock found.\r\n"
.kmsg_ok: .asciz "Superblock ok\r\n"

.section .text
.code16
.global sb_run

# sb_run()
sb_run:
	push %es
	push %si
	push %bx

	push $DNUM_SB
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	# {{{ (sb_mag != mag) ? {make} : {init}
	mov %es:SB_OFF_MAG(%bx), %ax
	cmp $(SB_MAG&0xFFFF), %ax
	jne .run__make
	mov %es:SB_OFF_MAG+0x02(%bx), %ax
	cmp $(SB_MAG>>0x10), %ax
	jne .run__make

	push $.kmsg_found
	call vga_puts
	add $0x02, %sp
	jmp .run__init
	# }}}

.run__make:
	push $.kmsg_try
	call vga_puts
	add $0x02, %sp

	# {{{ write superblock
	mov %bx, %si
	add $SB_OFF_TOT_SECT, %si
	call ata_get_sect
	mov %ax, (%si)
	mov %dx, 0x02(%si)

	push %bx
	push %es
	call sb_alloc_lba
	add $0x04, %sp

	# write magic
	mov $(SB_MAG&0xFFFF), %ax
	mov %ax, %es:SB_OFF_MAG(%bx)
	mov $(SB_MAG>>0x10), %ax
	mov %ax, %es:SB_OFF_MAG+0x02(%bx)

	push $DNUM_SB
	call disk_write_sect
	add $0x02, %sp
	# }}}

	call _super_set_lba
	call _super_set_bitmap

	FS_INIT_INUM
	call sb_make_root
	jmp .done

.run__init:
	FS_INIT_INUM
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
