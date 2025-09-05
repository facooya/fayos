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

	# kernel
	mov $0x1000, %di
	call .read_disk
	ljmp $0x0000, $0x1000

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

# .outbs(&str) - out boot string
.outbs:
	push %bp
	mov %sp, %bp
	push %es

	mov 0x04(%bp), %si

	# vid init
	mov $0xB000, %ax
	mov %ax, %es
	mov $0x8000, %di

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

	mov %ax, %cx # pos
	# }}}

.outbs__lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .outbs__done

	# (chr != newline) ? {out}
	cmp $0x5C, %al
	jne .outbs__lp_out
	mov 0x01(%si), %ah
	cmp $0x6E, %ah
	jne .outbs__lp_out

	mov $0x0A, %al
	mov %al, %es:(%di)
	add $0x01, %di
	jmp .outbs__lp_out_skip

.outbs__lp_out:
	# out
	mov %al, %es:(%di)
	add $0x01, %di

.outbs__lp_out_skip:
	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	add $0x01, %si
	add $0x01, %cx # pos
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

# .clrdisp()
.clrdisp:
	push %es

	# vid init
	mov $0xB000, %ax
	mov %ax, %es
	mov $0x8000, %di

	# TODO: get display size
	mov $0x07D0, %cx

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
	# TODO: set cursor
	pop %es
	ret

# bmsg
.bmsg_fayos: .asciz "FAYOS\n"

# end
.fill 0x01FE-(.-_start), 0x01, 0x00
.word 0xAA55
