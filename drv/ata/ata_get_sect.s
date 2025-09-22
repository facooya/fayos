# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get total sectors

.section .text
.code16
.global ata_get_sect

# ata_get_sect()
# <ret> dx:ax = sect
ata_get_sect:
	push %bx

	# set drv
	mov $0x01F6, %dx
	mov $0xA0, %al # master
	out %al, %dx

	mov $0x01F7, %dx

.bsy__lp:
	in %dx, %al
	test $0x80, %al
	jnz .bsy__lp

	mov $0xEC, %al # identify device
	out %al, %dx

.drq__lp:
	in %dx, %al
	test $0x08, %al
	jz .drq__lp

	mov $0x01F0, %dx
	mov $0x0100, %cx
	xor %bx, %bx

.data__lp:
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz .data__end

	in %dx, %ax
	cmp $0x64, %bx
	je .get_total_sect

	sub $0x01, %cx
	add $0x01, %bx
	jmp .data__lp

.get_total_sect:
	push %ax # [s.d0:sect_lo]
	in %dx, %ax
	add $0x01, %bx
	push %ax # [s.d1:sect_hi]

	add $0x01, %bx
	jmp .data__lp

.data__end:
	pop %dx # [s.d1:sect_hi]
	pop %ax # [s.d0:sect_lo]

	pop %bx
	ret
