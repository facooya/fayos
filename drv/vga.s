# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/vga.inc"
.section .text
.code16
.global vga_init
.global vga_clr
.global vga_clr_line
.global vga_init_curs
.global vga_get_curs
.global vga_set_curs
.global vga_outc
.global vga_outs
.global vga_outns

# vga_init()
# <mod: vga_last_row_off, vga_size>
vga_init:
	xor %ax, %ax
	mov (VGA_ADDR_ROW), %al
	mov (VGA_ADDR_COL), %cx

	xor %dx, %dx
	mul %cx
	mov %ax, (vga_last_row_off)

	add %cx, %ax
	mov %ax, (vga_size)
	ret

# vga_clr()
# <req: vga_size>
vga_clr:
	push %es
	push %di
	push %bx

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	mov (vga_size), %cx

	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	xor %ax, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %es
	ret

# vga_clr_line()
vga_clr_line:
	push %es
	push %di
	push %bx

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	call vga_get_curs

	mov (VGA_ADDR_COL), %cx

	# get current line [line_idx=curs_pos/col]
	xor %dx, %dx
	div %cx
	mov %ax, %cx # line_idx

	# [line_start_pos=col*line_idx]
	mov (VGA_ADDR_COL), %ax
	mul %cx
	add %ax, %di
	add %ax, %di

	push %ax
	call vga_set_curs
	add $0x02, %sp

	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	pop %bx
	pop %di
	pop %es
	ret

# vga_init_curs()
# <mod: curs>
vga_init_curs:
	call vga_get_curs
	mov %ax, (curs)
	mov %ax, (curs+0x02)
	ret

# vga_get_curs()
# <ret: ax = pos>
# ax / column = y
# ax % column = x
vga_get_curs:
	xor %ax, %ax

	# high
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_HI, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	in %dx, %al
	mov %al, %ah

	# low
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_LO, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	in %dx, %al
	ret

# vga_set_curs(ub16 pos)
vga_set_curs:
	push %bp
	mov %sp, %bp

	# high
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_HI, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov 0x04(%bp), %ax
	mov %ah, %al
	out %al, %dx

	# low
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_LO, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov 0x04(%bp), %ax
	out %al, %dx

	pop %bp
	ret

# vga_outc()
# <req: al = chr>
# <req: vga_size, vga_last_row_off>
vga_outc:
	push %es
	push %si
	push %di
	push %bx

	# esc chrs
	cmp $CHR_CR, %al
	je 20f
	cmp $CHR_LF, %al
	je 21f

	# init
	push %ax # [s.0:chr]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	call vga_get_curs
	mov (vga_size), %cx

	# (cur_curs >= vga_size) ? {shu.chr}
	cmp %cx, %ax
	jge 30f

	add %ax, %di # curs_pos
	add %ax, %di

	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp
	pop %ax # [s.0:chr]

10: # put
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)
	add $0x02, %di
	jmp 99f

20: # cr
	call vga_get_curs
	mov %ax, %bx # curs_pos

	mov (VGA_ADDR_COL), %cx

	# [curs_pos - (curs_pos % col)]
	xor %dx, %dx
	div %cx
	sub %dx, %bx
	xor %di, %di
	add %bx, %di
	add %bx, %di

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp 99f

21: # lf
	call vga_get_curs
	mov %ax, %bx # cur_curs_pos

	mov (VGA_ADDR_COL), %cx
	add %cx, %bx # curs_pos
	add %cx, %di
	add %cx, %di

	# (curs_pos >= vga_size) ? {shu}
	mov (vga_size), %ax
	cmp %ax, %bx
	jge 31f

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp 99f

30: # shu chr
	mov (VGA_ADDR_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]

	# clr line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	mov (vga_last_row_off), %ax
	mov %ax, %di
	add %ax, %di

	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	pop %ax # [s.0:chr]
	jmp 10b

31: # shu lf
	# init
	mov (VGA_ADDR_COL), %ax
	sub %ax, %bx # curs_pos
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]

	# clr line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	# set
	mov %bx, %di
	add %bx, %di

	push %bx
	call vga_set_curs
	add $0x02, %sp

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# vga_outs(*str)
# <req: vga_size, vga_last_row_off>
vga_outs:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	call vga_get_curs
	add %ax, %di
	add %ax, %di
	mov %ax, %cx # cur_curs
	mov (vga_size), %bx

10: # loop
	# (chr == null) ? {done}
	mov (%si), %al
	test %al, %al
	jz 90f

	cmp $CHR_CR, %al
	je 20f
	cmp $CHR_LF, %al
	je 21f

	# (curs_pos >= vga_size) ? {shu.in}
	cmp %bx, %cx
	jge 30f

11: # out
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)
	add $0x02, %di

	inc %si
	inc %cx # cur_curs
	jmp 10b

20: # cr
	push %bx # [s.l0:vga_size]
	mov %cx, %ax # cur_curs
	mov (VGA_ADDR_COL), %bx # col

	# [cur_curs - (cur_curs % col)]
	xor %dx, %dx
	div %bx
	sub %dx, %cx # cur_curs
	sub %dx, %di
	sub %dx, %di

	pop %bx # [s.l0:vga_size]
	inc %si
	jmp 10b

21: # lf
	mov (VGA_ADDR_COL), %ax
	add %ax, %cx
	add %ax, %di
	add %ax, %di

	# (cur_curs >= vga_size) ? {shu} : {lp}
	mov (vga_size), %ax
	cmp %ax, %cx
	jge 31f
	inc %si
	jmp 10b

30: # shu in
	push %si # [s.l1:str]
	push %ax # [s.l0:chr]

	# init
	mov (VGA_ADDR_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]

	# clr line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	mov (vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	pop %si # [s.l1:str]
	jmp 11b

31: # shu
	# init
	push %si # [s.l0:str]
	mov (VGA_ADDR_COL), %ax
	sub %ax, %cx
	mov %cx, %dx # curs_pos
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]
	pop %si # [s.l0:str]

	# clr last line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	# set
	mov %dx, %cx # curs_pos
	mov %dx, %di
	add %dx, %di

	inc %si
	jmp 10b

90:
	push %cx # cur_curs
	call vga_set_curs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# vga_outns(num, *str)
# <req: vga_size, vga_last_row_off>
vga_outns:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x06(%bp), %si

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	call vga_get_curs
	add %ax, %di
	add %ax, %di
	mov %ax, %cx # cur_curs
	mov (vga_size), %bx
	mov 0x04(%bp), %dx # num

10:
	# (num == 0) ? {done}
	test %dx, %dx
	jz 90f

	mov (%si), %al
	cmp $CHR_CR, %al
	je 20f
	cmp $CHR_LF, %al
	je 21f

	# (curs_pos >= vga_size) ? {shu.in}
	cmp %bx, %cx
	jge 30f

11:
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)
	add $0x02, %di

	inc %si
	inc %cx # cur_curs
	dec %dx # num
	jmp 10b

20: # cr
	push %bx # [s.l0:vga_size]
	push %dx # [s.l1:len]
	mov %cx, %ax # cur_curs
	mov (VGA_ADDR_COL), %bx # col

	# [cur_curs - (cur_curs % col)]
	xor %dx, %dx
	div %bx
	sub %dx, %cx # cur_curs
	sub %dx, %di
	sub %dx, %di

	pop %dx # [s.l1:len]
	pop %bx # [s.l0:vga_size]
	inc %si
	dec %dx # num
	jmp 10b

21: # lf
	mov (VGA_ADDR_COL), %ax
	add %ax, %cx
	add %ax, %di
	add %ax, %di

	# (cur_curs >= vga_size) ? {shu} : {lp}
	mov (vga_size), %ax
	cmp %ax, %cx
	jge 31f
	inc %si
	dec %dx # len
	jmp 10b

30: # shu in
	push %si # [s.l1:str]
	push %ax # [s.l0:chr]

	# init
	mov (VGA_ADDR_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]

	# clr line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	mov (vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	pop %si # [s.l1:str]
	jmp 11b

31: # shu
	push %dx # [s.l1:len]

	# init
	push %si # [s.l0:str]
	mov (VGA_ADDR_COL), %ax
	sub %ax, %cx
	mov %cx, %dx # curs_pos
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]
	pop %si # [s.l0:str]

	# clr last line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	# set
	mov %dx, %cx # curs_pos
	mov %dx, %di
	add %dx, %di

	pop %dx # [s.l1:len]

	inc %si
	dec %dx # len
	jmp 10b

90:
	push %cx # cur_curs
	call vga_set_curs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

.section .data
.global vga_size
.global vga_last_row_off
vga_size: .word 0x00
vga_last_row_off: .word 0x00
