# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# set DAP by block LBA

.include "fayfs/super.s"
.include "fayfs/inode.s"
.section .data
.blk_lba: .long 0x00

.section .text
.code16
.global set_dap_blk_lba

# set_dap_blk_lba(struct inode *inode)
set_dap_blk_lba:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	# calc low
	mov 0x04(%bp), %si
	add $I_BLK_0_OFF, %si
	mov (%si), %ax

	xor %dx, %dx
	mov $0x08, %cx
	mul %cx

	mov %ax, (.blk_lba)
	mov %dx, (.blk_lba+0x02)

	# calc high
	mov 0x02(%si), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx

	# {err} block overflow
	test %dx, %dx
	jnz .err

	# {err} high carry
	mov (.blk_lba+0x02), %dx
	clc
	add %ax, %dx
	jc .err

	mov %dx, (.blk_lba+0x02)

	# add normal lba
	mov (.blk_lba), %ax
	mov $S_OFF_MEM, %bx
	mov NORM_LBA_OFF(%bx), %cx
	# TODO: NORM_LBA_OFF+0x02(%bx)

	clc
	add %cx, %ax
	jc .carry

	mov %ax, (.blk_lba)
	jmp .end
	# }}}

.carry:
	mov %ax, (.blk_lba)
	mov (.blk_lba+0x02), %ax
	add $0x01, %ax
	mov %ax, (.blk_lba+0x02)
	jmp .end

.end:
	mov (.blk_lba), %ax
	push %ax # lo
	mov (.blk_lba+0x02), %ax
	push %ax # hi
	call set_dap_lba
	add $0x04, %sp

.epil:
	pop %bx
	pop %si
	pop %bp
	ret

.err:
	jmp .epil
