# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Lookup directory entry

.include "fayfs/dentry.s"
.section .text
.code16
.global lookup_dentry

# lookup_dentry(
# *start_off
# file_size
# name_len,
# *name
# )
# <ret> ax = not_match:1, match:offset
lookup_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {init}
	mov 0x04(%bp), %bx # *start_off
	mov 0x06(%bp), %cx # file_size
	mov 0x08(%bp), %dx # name_len
	mov 0x0A(%bp), %si # *name

.lp:
	# {end.done.nm} (file_size <= 0)
	cmp $0x00, %cx
	jle .done__nm

	# {{{
	xor %ax, %ax
	mov DE_NAME_LEN_OFF(%bx), %al # dst_name_len

	# {lp.step} (src_name_len != dst_name_len)
	cmp %ax, %dx
	jne .lp__step

	# {lp.step} (inum == 0)
	mov DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or DE_INUM_OFF+0x02(%bx), %ax
	jz .lp__step
	# }}}

	# {{{ str compare
	mov %bx, %di
	add $DE_NAME_OFF, %di # dst_name

	push %cx
	push %dx
	xor %ax, %ax
	mov DE_NAME_LEN_OFF(%bx), %al
	push %ax # dst_name_len
	push %di # dst_name
	push %si # src_name
	call strncmp
	add $0x06, %sp
	pop %dx
	pop %cx

	# {end.done.m} (strncmp == true)
	test %ax, %ax
	jz .done__m
	# }}}

.lp__step:
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	sub %ax, %cx # file_size

	# {lp}
	jmp .lp

# {DONE}
.done__m:
	mov %bx, %ax
	mov 0x04(%bp), %cx # s_off
	sub %cx, %ax
	jmp .epil

.done__nm:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
