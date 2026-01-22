# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.section .text
.code16
.global puts
.global putns
.global putf
.global putc
.global putnl
.global putsp

# puts(ub16 seg, ub16 off)
# <mod: write_sbuf>
puts:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# init
	mov 0x04(%bp), %ax # (seg)
	mov %ax, %es
	mov 0x06(%bp), %si # (off)
	mov $write_sbuf, %di
	mov (%di), %bx # buf.size
	add $0x02, %di # skip size
	add %bx, %di # buf.in

1:
	# (str == null) ? {done}
	mov %es:(%si), %al
	test %al, %al
	jz 90f

	# store in write_sbuf
	mov %al, (%di)

	inc %si
	inc %di
	inc %bx
	jmp 1b
	
90:
	# store size
	mov $write_sbuf, %di
	mov %bx, (%di)

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# putns(ub16 seg, ub16 off, ub16 num)
putns:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# init
	mov 0x04(%bp), %ax # (seg)
	mov %ax, %es
	mov 0x06(%bp), %si # (off)
	mov 0x08(%bp), %cx # num
	mov $write_sbuf, %di
	mov (%di), %bx # buf.size
	add $0x02, %di # skip size
	add %bx, %di # buf.in

1:
	# (num == 0) ? {done}
	test %cx, %cx
	jz 90f

	# copy in write_sbuf
	mov %es:(%si), %al
	mov %al, (%di)

	inc %si
	inc %di
	inc %bx
	dec %cx # num
	jmp 1b

90:
	# store size
	mov $write_sbuf, %di
	mov %bx, (%di)

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# putf(ub16 seg, ub16 off)
# <mod: write_sbuf>
putf:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# init
	mov 0x04(%bp), %ax # (seg)
	mov %ax, %es
	mov 0x06(%bp), %si # (off)
	mov $write_sbuf, %di
	mov (%di), %bx # buf.len
	add $0x02, %di # skip len
	add %bx, %di # buf.in

1:
	# (str == null) ? {done}
	mov %es:(%si), %al
	test %al, %al
	jz 90f

	# (str == bsl) ? {backslash}
	cmp $CHR_BSL, %al
	je 10f

	# store in write_sbuf
	mov %al, (%di)

	inc %si
	inc %di
	inc %bx
	jmp 1b

10: # disp backslash
	mov %es:0x01(%si), %al

	# (chr == null) ? {done}
	test %al, %al
	jz 90f
	
	# (chr == n)
	cmp $CHR_LC_N, %al
	je 11f

	# (chr == bsl)
	cmp $CHR_BSL, %al
	je 12f

	inc %si
	jmp 1b

11: # hdl newline
	mov $CHR_CR, %al
	mov %al, (%di)
	mov $CHR_LF, %al
	mov %al, 0x01(%di)

	add $0x02, %di # add CR, LF
	add $0x02, %bx
	add $0x02, %si # skip \n
	jmp 1b

12: # hdl backslash
	mov %al, (%di)
	inc %di # add BSL
	inc %bx
	add $0x02, %si # skip \\
	jmp 1b

90:
	# store size
	mov $write_sbuf, %di
	mov %bx, (%di)

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# putc()
# <req: al = chr>
# <mod: write_sbuf>
putc:
	push %si
	push %bx

	# init
	mov $write_sbuf, %si
	mov (%si), %bx # buf.size
	add $0x02, %si # skip size
	add %bx, %si # buf.in

	# store data
	mov %al, (%si)
	inc %bx

	# store size
	mov $write_sbuf, %si
	mov %bx, (%si)

	pop %bx
	pop %si
	ret

# putnl()
# <mod: write_sbuf>
putnl:
	push %si
	push %bx

	# init
	mov $write_sbuf, %si
	mov (%si), %bx # buf.size
	add $0x02, %si # skip size
	add %bx, %si # buf.in

	# store data
	mov $CHR_CR, %al
	mov %al, (%si)
	inc %si
	inc %bx

	mov $CHR_LF, %al
	mov %al, (%si)
	inc %bx

	# store size
	mov $write_sbuf, %si
	mov %bx, (%si)

	pop %bx
	pop %si
	ret

# putsp()
# <mod: write_sbuf>
putsp:
	push %si
	push %bx

	# init
	mov $write_sbuf, %si
	mov (%si), %bx # buf.size
	add $0x02, %si # skip size
	add %bx, %si # buf.in

	# store data
	mov $CHR_SP, %al
	mov %al, (%si)
	inc %bx

	# store size
	mov $write_sbuf, %si
	mov %bx, (%si)

	pop %bx
	pop %si
	ret
