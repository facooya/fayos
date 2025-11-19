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

	push $DISK_SB_SECT_CNT # (sect_cnt)
	push $DISK_SB_LBA # (lba)
	push $(DISK_SB_MEM&0xFFFF) # (&off)
	push $(DISK_SB_MEM>>0x10) # (&seg)
	call ata_read_sect
	add $0x08, %sp
	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx

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

	call sb_write_dpi

	push $DISK_SB_SECT_CNT # (sect_cnt)
	push $DISK_SB_LBA # (lba)
	push $(DISK_SB_MEM&0xFFFF) # (&off)
	push $(DISK_SB_MEM>>0x10) # (&seg)
	call ata_write_sect
	add $0x08, %sp
	# }}}

	call disk_set_dpi
	call disk_load_dpi
	call sb_set_bm

	# { make root dir
	push $F_TYPE_DIR # (f_type)
	call ind_add
	add $0x02, %sp
	# <ax = inum>

	call fsp_init
	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp
	call fsp_init
	# }
	jmp .done

.run__init:
	call disk_set_dpi
	call disk_load_dpi
	call fsp_init
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
