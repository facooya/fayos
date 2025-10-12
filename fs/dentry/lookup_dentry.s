# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Lookup directory entry

.include "fs/dentry.s"
.section .text
.code16
.global lookup_dentry

# lookup_dentry(
# *seg
# *off
# file_size
# name_len,
# *name
# )
# <ret> ax = not_match:1, match:offset
lookup_dentry:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# {init}
	mov 0x04(%bp), %ax
	mov %ax, %es # *seg
	mov 0x06(%bp), %bx # *off
	mov 0x08(%bp), %cx # file_size
	mov 0x0A(%bp), %dx # name_len
	mov 0x0C(%bp), %si # *name
	# TODO: *name_seg, *name_off

.lp:
	# {end.done.nm} (file_size <= 0)
	cmp $0x00, %cx
	jle .done__nm

	# {{{
	xor %ax, %ax
	mov %es:DE_NAME_LEN_OFF(%bx), %al # dest_name_len

	# {lp.step} (src_name_len != dest_name_len)
	cmp %ax, %dx
	jne .lp__step

	# {lp.step} (inum == 0)
	mov %es:DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or %es:DE_INUM_OFF+0x02(%bx), %ax
	jz .lp__step
	# }}}

	# {{{ compare
	mov %bx, %di
	add $DE_NAME_OFF, %di # dest_name

	push %cx
	push %dx
	push %es

	xor %ax, %ax
	mov %es:DE_NAME_LEN_OFF(%bx), %al
	push %ax # size
	push %si # *src_off
	xor %ax, %ax # TODO: *name_seg
	push %ax # *src_seg
	push %di # *dest_off
	push %es # *dest_seg
	call memcmp
	add $0x0A, %sp

	pop %es
	pop %dx
	pop %cx

	# {end.done.m} (memcmp() == true)
	test %ax, %ax
	jz .done__m
	# }}}

.lp__step:
	mov %es:DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	sub %ax, %cx # file_size

	# {lp}
	jmp .lp

# {DONE}
.done__m:
	mov %bx, %ax
	mov 0x06(%bp), %cx # *off
	sub %cx, %ax
	jmp .epil

.done__nm:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
