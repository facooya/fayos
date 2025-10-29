# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Keyborad] Arrow key up

.include "fs/inode.s"
.include "fs/dentry.s"
.section .text
.code16
.global kbd_key_up

# kbd_key_up()
kbd_key_up:
	# (hist_idx == 0) ? {done}
	mov (hist_idx), %ax
	test %ax, %ax
	jz .done

	# (hist_idx == line_count) ? {save} : {cont}
	mov (file_lines), %cx
	cmp %cx, %ax
	je .save
	dec %ax
	mov %ax, (hist_idx)
	jmp .cont

.save:
	dec %ax
	mov %ax, (hist_idx)

	# (len == 0) ? {cont}
	mov (cl_lbuf), %ax
	test %ax, %ax
	jz .cont

	push $cl_hist_lbuf
	call bufzero
	add $0x02, %sp

	push $cl_lbuf
	push $cl_hist_lbuf
	call bufcpy
	add $0x04, %sp

.cont:
	call hist_upd_cl
	jmp .done

.done:
	ret
