# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Bootloader

# .include "boot_equ.s"
.code16
.global _start

# _start()
_start:
	# clear interrupt
	cli

	# init
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov %ax, %sp
	mov %ax, %bp

	# set stack
	mov $0x7C00, %sp

	call .clrdisp
	push $.bmsg_fayos
	call .outbs
	add $0x02, %sp
	push $.bmsg_a
	call .outbs
	add $0x02, %sp

	# kernel
	mov $0x1000, %di
	call .read_disk
	ljmp $0x0000, $0x1000

# {FUNC}
# kernel - count:0x30, lba:0x10, 0x0000:0x1000
.read_disk:
	# set mode
	mov $0x01F6, %dx
	mov $0xE0, %al # 0b11100000
	out %al, %dx

	# sector count
	mov $0x01F2, %dx
	mov $0x30, %al
	mov $0x30, %bx
	out %al, %dx

	# {{{ LBA
	mov $0x01F3, %dx
	mov $0x10, %al # kernel lba
	out %al, %dx

	mov $0x01F4, %dx
	mov $0x00, %al
	out %al, %dx

	mov $0x01F5, %dx
	mov $0x00, %al
	out %al, %dx
	# }}}

	# read
	mov $0x01F7, %dx
	mov $0x20, %al
	out %al, %dx
	jmp .drq__lp

.sec__lp:
	mov $0x01F7, %dx

.drq__lp:
	in %dx, %al
	test $0x08, %al
	jz .drq__lp

	# TODO: error

	mov $0x01F0, %dx
	mov $0x0100, %cx
	sub $0x01, %bx # sector count

.data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .data__end

	in %dx, %ax
	mov %ax, %es:(%di)

	# {lp}
	sub $0x01, %cx
	add $0x02, %di
	jmp .data__lp

.data__end:
	# (sector == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz .disk__done
	jmp .sec__lp

.disk__done:
	ret

# {FUNC}
# .outbs(&str) - out boot string
.outbs:
	push %bp
	mov %sp, %bp
	push %es

	mov 0x04(%bp), %si

	# vid init
	mov $0xB800, %ax
	mov %ax, %es
	xor %di, %di

	# {{{ get cursor
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	in %dx, %al
	mov %al, %ah

	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	in %dx, %al

	# skip outc, conf
	add %ax, %di
	add %ax, %di

	mov %ax, %cx # pos
	# }}}

.outbs__lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .outbs__done

	# (chr == newline) ? {newline}
	cmp $0x0A, %al
	je .outbs__newline

	# out
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	add $0x01, %si
	add $0x01, %cx # pos
	jmp .outbs__lp

.outbs__newline:
	# {{{ newline
	push %cx
	mov $0x044A, %bx
	mov (%bx), %cx # col

	xor %dx, %dx
	mov %di, %ax
	div %cx
	sub %dx, %di # init col

	# skip out, conf
	add %cx, %di
	add %cx, %di

	pop %cx
	# }}}

	# cursor pos
	mov %di, %ax
	mov $0x02, %cx
	xor %dx, %dx
	div %cx
	mov %ax, %cx

	add $0x01, %si
	jmp .outbs__lp

.outbs__done:
	# {{{ set cursor
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	mov %ch, %al
	out %al, %dx

	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	mov %cl, %al
	out %al, %dx
	# }}}

	pop %es
	pop %bp
	ret

# {FUNC}
# .clrdisp()
.clrdisp:
	push %es

	# vid init
	mov $0xB000, %ax
	mov %ax, %es
	mov $0x8000, %di

	# {{{ get disp
	xor %dx, %dx
	mov $0x0484, %bx
	mov (%bx), %dl

	mov $0x044A, %bx
	mov (%bx), %ax
	# }}}

	mul %dx
	mov %ax, %cx

.clrdisp__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .clrdisp__end

	# clear
	mov $0x20, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	sub $0x01, %cx
	jmp .clrdisp__lp

.clrdisp__end:
	# {{{ set cursor
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	xor %al, %al
	out %al, %dx

	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	xor %al, %al
	out %al, %dx
	# }}}

	pop %es
	ret

# {DATA}
.bmsg_fayos: .asciz "FAYOS\n\n"
.bmsg_a: .asciz "AAA"

# {DONE}
.fill 0x01FE-(.-_start), 0x01, 0x00
.word 0xAA55
