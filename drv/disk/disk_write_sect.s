# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Write sectors

.section .text
.code16
.global disk_write_sect

# disk_write_sect(ub16 dnum)
# <req> dio
disk_write_sect:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	mov (dnum), %ax
	mov $0x0A, %cx # dio_type_size
	mul %cx
	# ax = dio_off

	mov $dio, %si
	add %ax, %si # dio_off
	
	mov (%si), %ax
	push %ax # sect_cnt
	mov 0x08(%si), %ax
	push %ax # lba_lo
	mov 0x06(%si), %ax
	push %ax # lba_hi
	mov 0x04(%si), %ax
	push %ax # off
	mov 0x02(%si), %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp

.done:
	pop %bx
	pop %si
	pop %bp
	ret
