# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Debug] File System Packet

.include "chr.s"
.include "fs/fs.s"
.section .data
.ind_ptr_str: .asciz "ind_ptr"
.inum_str: .asciz "inum"
.disk_lba_str: .asciz "disk_lba"
.section .text
.code16
.global dbg_fsp

# dbg_fsp(fsp *src)
dbg_fsp:
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	mov 0x04(%bp), %si

	mov FSP_OFF_F_SIZE(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	mov FSP_OFF_F_TYPE(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	mov FSP_OFF_BLK(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $.ind_ptr_str
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	mov FSP_OFF_IND_PTR+0x02(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov FSP_OFF_IND_PTR(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $.inum_str
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	mov FSP_OFF_INUM(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $.disk_lba_str
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	mov FSP_OFF_DISK_LBA(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	pop %ax
	pop %si
	pop %bp
	ret
