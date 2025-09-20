# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read sectors

# reference link
# https://wiki.osdev.org/ATA_read/write_sectors#Read_in_LBA_mode

.section .text
.code16
.global ata_read_sect

# ata_read_sect(
# seg, off,
# lba_hi, lba_lo,
# sect_cnt
# )
ata_read_sect:
	push %bp
	mov %sp, %bp
	push %es
	push %di
	push %bx

	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %di

	# set mode
	mov $0x01F6, %dx
	mov $0xE0, %al # 0b11100000
	out %al, %dx

	# sector count
	mov $0x01F2, %dx
	mov 0x0C(%bp), %ax # sect_cnt
	mov %ax, %bx # sect_cnt
	out %al, %dx

	# {{{ LBA
	mov $0x01F3, %dx
	mov 0x0A(%bp), %ax # lba_lo
	out %al, %dx

	mov $0x01F4, %dx
	mov %ah, %al # lba_mid
	out %al, %dx

	mov $0x01F5, %dx
	mov 0x08(%bp), %ax # lba_hi
	out %al, %dx
	# }}}

	# read
	mov $0x01F7, %dx
	mov $0x20, %al
	out %al, %dx
	jmp .drq__lp

.sect__lp:
	mov $0x01F7, %dx

.drq__lp:
	in %dx, %al
	test $0x08, %al
	jz .drq__lp

	# TODO: err

	mov $0x01F0, %dx
	mov $0x0100, %cx
	sub $0x01, %bx # sect_cnt

.data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .data__end

	# load
	in %dx, %ax
	mov %ax, %es:(%di)

	# {lp}
	sub $0x01, %cx
	add $0x02, %di
	jmp .data__lp

.data__end:
.bsy__lp:
	mov $0x01F7, %dx
	in %dx, %al
	test $0x80, %al
	jnz .bsy__lp

	# (sect_cnt == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz .done
	jmp .sect__lp

.done:
	pop %bx
	pop %di
	pop %es
	pop %bp
	ret
