# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read disk

# reference link
# https://wiki.osdev.org/ATA_read/write_sectors#Read_in_LBA_mode

.section .text
.code16
.global read_disk3

# read_disk3(*dap)
read_disk3:
	push %bp
	mov %sp, %bp

	# set mode
	mov $0x01F6, %dx
	mov $0xE0, %al # 0b11100000
	out %al, %dx

	# sector count
	mov $0x01F2, %dx
	mov $0x01, %al
	out %al, %dx

	# {{{ LBA
	mov $0x01F3, %dx
	mov $0x80, %al # root lba
	out %al, %dx

	mov $0x01F4, %dx
	mov $0x00, %al
	out %al, %dx

	mov $0x01F5, %dx
	mov $0x00, %al
	out %al, %dx
	# }}}

	# read
	mov $0x01F7, %dx
	mov $0x20, %al
	out %al, %dx

.drq__lp:
	in %dx, %al
	test $0x08, %al
	jz .drq__lp

	mov $0x01F0, %dx
	mov $0x10, %cx

.data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .data__end

	in %dx, %al

	push %cx
	push %dx
	push %ax
	call dbg_reg
	pop %ax
	pop %dx
	pop %cx

	# {lp}
	sub $0x01, %cx
	jmp .data__lp

.data__end:
	call dbg_c

	pop %bp
	ret
