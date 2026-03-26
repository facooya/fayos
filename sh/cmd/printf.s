# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.section .text
.code16
.global cmd_printf

# cmd_printf()
# <ret: ax = ret_code>
cmd_printf:
	push %si
	push %di
	push %bx

	mov $arg_ccv, %di
	mov (%di), %cx # argc
	add $0x06, %di # skip ccv

	mov $cl_sbuf, %si
	add $0x02, %si # skip size
	mov (%di), %cx
	add %cx, %si

	push %si
	push %ds
	call putf
	add $0x04, %sp

	add $0x02, %di
	mov (%di), %cx
	mov $cl_sbuf, %bx
	add $0x02, %bx
	add %cx, %bx # string

	mov $write_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0: cnt]
	mov $tmp_sbuf, %di
	mov (%di), %ax
	add $0x02, %di
	push %ax # (size)
	xor %ax, %ax
	push %ax # (val)
	push $tmp_sbuf+0x02 # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp
	pop %cx # [s.f0: cnt]

	xor %dx, %dx

1:
	test %cx, %cx
	jz 9f

	mov (%si), %al
	cmp $0x25, %al
	je 2f

	mov %al, (%di)

	inc %si
	inc %di
	dec %cx
	inc %dx
	jmp 1b

2: # percent
	mov 0x01(%si), %al
	cmp $0x73, %al
	je 3f

	mov $0x25, %al
	mov %al, (%di)

	inc %si
	inc %di
	dec %cx
	inc %dx
	jmp 1b

3: # string
	mov (%bx), %al
	test %al, %al
	jz 4f

	mov %al, (%di)

	inc %bx
	inc %di
	inc %dx
	jmp 3b

4:
	add $0x02, %si
	sub $0x02, %cx
	jmp 1b

9:
	mov %dx, (tmp_sbuf)
	mov (write_sbuf), %ax
	push %ax # (size)
	xor %ax, %ax
	push %ax # (val)
	push $write_sbuf+0x02 # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp

	mov (tmp_sbuf), %ax
	mov %ax, (write_sbuf)
	push %ax # (size)
	push $tmp_sbuf+0x02 # (s_off)
	push %ds # (s_seg)
	push $write_sbuf+0x02 # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	jmp 90f

90:
	xor %ax, %ax
	pop %bx
	pop %di
	pop %si
	ret
