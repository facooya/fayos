# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Keyboard] Arrow key down

.section .text
.code16
.global kbd_key_down

# kbd_key_down()
kbd_key_down:
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
	push $cl_lbuf
	call bufzero
	add $0x02, %sp

	xor %ax, %ax
	mov (cl_hist_lbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push $cl_hist_lbuf # (*s_off)
	push %ax # (*s_seg)
	push $cl_lbuf # (*d_off)
	push %ax # (*d_seg)
	call mem_cpy
	add $0x0A, %sp

	call vga_clr_line

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs

	mov $cl_lbuf, %si
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

