# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_up

# kbd_hdl_up()
# <req> file_lines
# <mod> cl_sbuf, cl_hist_sbuf, hist_idx
kbd_hdl_up:
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
	mov (cl_sbuf), %ax
	test %ax, %ax
	jz .cont

	# zero
	xor %ax, %ax
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	# cpy
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push $cl_sbuf # (*s_off)
	push %ax # (*s_seg)
	push $cl_hist_sbuf # (*d_off)
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
