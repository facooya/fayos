# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write disk

# reference link
# https://wiki.osdev.org/ATA_read/write_sectors#ATA_write_sectors

.section .text
.code16
.global write_disk2

# write_disk2(*dap)
write_disk2:
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

	# write
	mov $0x01F7, %dx
	mov $0x30, %al
	out %al, %dx

.drq__lp:
	in %dx, %al
	test $0x08, %al
	jz .drq__lp

	mov $0x01F0, %dx
	mov $0x0100, %cx

.data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .data__end

	mov $0x61, %ax
	out %ax, %dx

	# {lp}
	sub $0x01, %cx
	jmp .data__lp

.data__end:

.bsy__lp:
	mov $0x01F7, %dx
	in %dx, %al
	test $0x80, %al
	jnz .bsy__lp

	call dbg_b

	pop %bp
	ret
