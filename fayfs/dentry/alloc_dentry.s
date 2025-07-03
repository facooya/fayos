# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate directory entry

.include "fayfs/de.s"
.section .text
.code16
.global alloc_dentry

# alloc_dentry()
# <pre> bx = main mem ptr
alloc_dentry:
	push %bx

.lp:
	# {lp} (i_num == 0)
	mov DE_I_NUM_LO_OFF(%bx), %ax
	test %ax, %ax
	or DE_I_NUM_HI_OFF(%bx), %ax
	jz .lp__step

.lp__step:
	# {end} (rec_len == null)
	mov DE_REC_LEN_OFF(%bx), %ax
	test %ax, %ax
	jz .end

	# {lp}
	add %ax, %bx
	jmp .lp

.end:
	# <ret>
	mov %bx, %ax

	# FIXME: remove dentry_ptr
	sub $0x8000, %ax
	mov %ax, (dentry_ptr)

	pop %bx
	ret
