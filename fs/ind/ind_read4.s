# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Read index node table and make indp

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_read4

# ind_read4(indp *indp, ub16 inum_hi, ub16 inum_lo)
ind_read4:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# save inum
	mov 0x04(%bp), %di
	mov 0x06(%bp), %ax
	mov %ax, INDP_OFF_INUM+0x02(%di)
	mov 0x08(%bp), %ax
	mov %ax, INDP_OFF_INUM(%di)

	# { save ptr
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %si

	xor %dx, %dx
	mov 0x08(%bp), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %si

	mov %es, INDP_OFF_IND_PTR+0x02(%di)
	mov %si, INDP_OFF_IND_PTR(%di)
	# }

	mov $IND_SIZE, %cx

.lp:
	test %cx, %cx
	jz .done

	# cpy inode
	mov %es:(%si), %ax
	mov %ax, (%di)

	add $0x02, %si
	add $0x02, %di
	sub $0x02, %cx
	jmp .lp

.done:
	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
