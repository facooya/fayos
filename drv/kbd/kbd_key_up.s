# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Keyborad] Arrow key up

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

	# zero
	xor %ax, %ax
	mov (cl_hist_lbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_lbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	# cpy
	xor %ax, %ax
	mov (cl_lbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push $cl_lbuf # (*s_off)
	push %ax # (*s_seg)
	push $cl_hist_lbuf # (*d_off)
	push %ax # (*d_seg)
	call mem_cpy
	add $0x0A, %sp

.cont:
	call hist_upd_cl
	# <ax = cl_pos>
	mov %ax, %si

	jmp .done

.done:
	ret
