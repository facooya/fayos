# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug for argc, optc, argv

.include "chr.s"
.section .data

.argc_str: .asciz "argc: "
.optc_str: .asciz "optc: "
.argv_str: .asciz "argv["
.argv_end_str: .asciz "]: "

.section .text
.code16
.global dbg_args

# dbg_args()
dbg_args:
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
	mov $cmd_lbuf, %si
	mov (%si), %bx
	add $0x02, %si

# {TASK}
	push $.argc_str
	call vga_puts
	add $0x02, %sp

	# get argc
	mov $args, %di
	mov (%di), %cx # argc
	add $0x02, %di # skip argc

	# byte to ascii
	mov %cx, %ax
	add $0x30, %al

	# argc
	call vga_putc
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

# {TASK}
	push $.optc_str
	call vga_puts
	add $0x02, %sp

	# get optc
	mov (%di), %ax # optc
	add $0x02, %di # skip optc

	# byte to ascii
	add $0x30, %al

	# optc
	call vga_putc
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .argv

# {TASK}
.argv:
	# {end.done} (argc == 0)
	test %cx, %cx # argc
	jz .done

	xor %dx, %dx # idx

.argv__lp:
	# {{{ out str
	push $.argv_str
	call vga_puts
	add $0x02, %sp

	# idx
	mov %dl, %al # idx
	add $0x30, %al
	call vga_putc

	push $.argv_end_str
	call vga_puts
	add $0x02, %sp
	# }}}

	# {{{
	# {init}
	mov $cmd_lbuf, %si
	add $0x02, %si # skip len

	# calc offset
	mov (%di), %ax # argv[i]
	add %ax, %si

	push %si
	call vga_puts
	add $0x02, %sp
	# }}}

	# {lp.step}
	add $0x02, %di # argv
	sub $0x01, %cx # argc
	add $0x01, %dx # idx

	# {end.done} (argc == 0)
	test %cx, %cx
	jz .done

	# {lp}
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
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
