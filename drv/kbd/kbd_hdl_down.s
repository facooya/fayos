# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_down

# kbd_hdl_down()
kbd_hdl_down:
	# upd hist_idx
	mov (hist_idx), %ax
	mov (file_lines), %cx

	# (hist_idx == line_count) ? {done}
	cmp %cx, %ax
	je .done

	inc %ax
	mov %ax, (hist_idx)

	# (hist_idx++ == line_count) ? {load} : {cont}
	cmp %cx, %ax
	je .load
	jmp .cont

.load:
	# zero
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	# cpy
	xor %ax, %ax
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push $cl_hist_sbuf # (&s_off)
	push %ax # (&s_seg)
	push $cl_sbuf # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	call vga_clr_line

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs

	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:len]
	push %si
	push %cx
	call vga_putls
	add $0x04, %sp
	pop %cx # [s.f0:len]
	add %cx, %si

	mov (curs), %ax
	add %ax, %cx
	mov %cx, (curs+0x02)
	jmp .done

.cont:
	call hist_upd_cl
	# <ax = cl_pos>
	mov %ax, %si
	jmp .done

.done:
	ret

