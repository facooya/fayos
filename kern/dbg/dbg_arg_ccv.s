# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Debug] arg_ccv

.include "chr.inc"
.section .data
.arg_c_str: .asciz "arg_c: "
.opt_c_str: .asciz "opt_c: "
.arg_v_str: .asciz "arg_v["
.arg_v_end_str: .asciz "]: "

.section .text
.code16
.global dbg_arg_ccv

# dbg_arg_ccv()
dbg_arg_ccv:
	push %si
	push %di
	push %ax
	push %bx
	push %cx
	push %dx

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	# {init}
	mov $cl_sbuf, %si
	mov (%si), %bx
	add $0x02, %si

# {TASK}
	push $.arg_c_str
	call vga_puts
	add $0x02, %sp

	# get arg_c
	mov $arg_ccv, %di
	mov (%di), %cx # arg_c
	add $0x02, %di # skip arg_c
	push %cx # [s.0:arg_c]

	# byte to ascii
	mov %cx, %ax
	add $0x30, %al

	# arg_c
	call vga_putc
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

# {TASK}
	push $.opt_c_str
	call vga_puts
	add $0x02, %sp

	# get opt_c
	mov (%di), %ax # opt_c
	add $0x02, %di # skip opt_c

	# byte to ascii
	add $0x30, %al

	# opt_c
	call vga_putc
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	pop %cx # [s.0:arg_c]
	jmp .argv

# {TASK}
.argv:
	# {end.done} (arg_c == 0)
	test %cx, %cx # arg_c
	jz .done

	xor %dx, %dx # idx

.argv__lp:
	push %cx # [s.0:arg_c]
	push %dx # [s.1:idx]
	# {{{ out str
	push $.arg_v_str
	call vga_puts
	add $0x02, %sp
	pop %dx # [s.1:idx]
	push %dx # [s.1:idx]

	# idx
	mov %dl, %al # idx
	add $0x30, %al
	call vga_putc

	push $.arg_v_end_str
	call vga_puts
	add $0x02, %sp
	# }}}

	# {{{
	# {init}
	mov $cl_sbuf, %si
	add $0x02, %si # skip size

	# calc offset
	mov (%di), %ax # arg_v[i]
	add %ax, %si

	push %si
	call vga_puts
	add $0x02, %sp
	# }}}
	pop %dx # [s.1:idx]
	pop %cx # [s.0:arg_c]

	add $0x02, %di # arg_v
	sub $0x01, %cx # arg_c
	add $0x01, %dx # idx

	# {end.done} (arg_c == 0)
	test %cx, %cx
	jz .done

	# {lp}
	push %cx # [s.f0:arg_c]
	push %dx # [s.f1:idx]
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	pop %dx # [s.f1:idx]
	pop %cx # [s.f0:arg_c]

	jmp .argv__lp

.done:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret
