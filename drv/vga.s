# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/vga.inc"
.include "drv/disk.inc"
.include "fs/fs.inc"
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
.global vga_shu
.global vga_shd

.global _vga_save_top # HACK

# vga_init()
# <mod: _vga_last_row_off, _vga_size>
vga_init:
	xor %ax, %ax
	mov (VGA_ADDR_ROW), %al
	mov (VGA_ADDR_COL), %cx

	xor %dx, %dx
	mul %cx
	mov %ax, (_vga_last_row_off)

	add %cx, %ax
	mov %ax, (_vga_size)
	ret

# vga_clr()
# <req: _vga_size>
vga_clr:
	push %es
	push %di
	push %bx

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	mov (_vga_size), %cx

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
# <req: _vga_size, _vga_last_row_off>
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
	mov (_vga_size), %cx

	# (cur_curs >= _vga_size) ? {shu.chr}
	cmp %cx, %ax
	jge 30f

	add %ax, %di # curs_pos
	add %ax, %di
	mov %ax, %cx
	inc %cx
	pop %ax # [s.0:chr]

10: # out
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)
	add $0x02, %di
	jmp 90f

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

	mov %bx, %cx
	jmp 90f

21: # lf
	call vga_get_curs
	mov %ax, %bx # cur_curs_pos

	mov (VGA_ADDR_COL), %cx
	add %cx, %bx # curs_pos
	add %cx, %di
	add %cx, %di

	# (curs_pos >= _vga_size) ? {shu}
	mov (_vga_size), %ax
	cmp %ax, %bx
	jge 31f

	mov %bx, %cx
	jmp 90f

30: # shu chr
	call _vga_shu

	mov (_vga_last_row_off), %ax
	mov %ax, %di
	add %ax, %di

	mov %ax, %cx
	inc %cx

	pop %ax # [s.0:chr]
	jmp 10b

31: # shu lf
	# init
	mov (VGA_ADDR_COL), %ax
	sub %ax, %bx # curs_pos

	call _vga_shu

	mov %bx, %cx # curs_pos
	jmp 90f

90:
	push %cx
	call vga_set_curs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# vga_outs(*str)
# <req: _vga_size, _vga_last_row_off>
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
	mov (_vga_size), %bx

10: # loop
	# (chr == null) ? {done}
	mov (%si), %al
	test %al, %al
	jz 90f

	cmp $CHR_CR, %al
	je 20f
	cmp $CHR_LF, %al
	je 21f

	# (curs_pos >= _vga_size) ? {shu.in}
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
	push %bx # [s.l0:_vga_size]
	mov %cx, %ax # cur_curs
	mov (VGA_ADDR_COL), %bx # col

	# [cur_curs - (cur_curs % col)]
	xor %dx, %dx
	div %bx
	sub %dx, %cx # cur_curs
	sub %dx, %di
	sub %dx, %di

	pop %bx # [s.l0:_vga_size]
	inc %si
	jmp 10b

21: # lf
	mov (VGA_ADDR_COL), %ax
	add %ax, %cx
	add %ax, %di
	add %ax, %di

	# (cur_curs >= _vga_size) ? {shu} : {lp}
	mov (_vga_size), %ax
	cmp %ax, %cx
	jge 31f
	inc %si
	jmp 10b

30: # shu in
	push %ax # [s.l0:chr]

	call _vga_shu

	# set curs pos
	mov (_vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	jmp 11b

31: # shu
	push %cx # [s.f0:curs_pos]
	call _vga_shu
	pop %cx # [s.f0:curs_pos]

	mov (VGA_ADDR_COL), %ax
	sub %ax, %cx
	mov %cx, %dx # curs_pos

	# set curs pos
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
# <req: _vga_size, _vga_last_row_off>
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
	mov (_vga_size), %bx
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

	# (curs_pos >= _vga_size) ? {shu.in}
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
	push %bx # [s.l0:_vga_size]
	push %dx # [s.l1:num]
	mov %cx, %ax # cur_curs
	mov (VGA_ADDR_COL), %bx # col

	# [cur_curs - (cur_curs % col)]
	xor %dx, %dx
	div %bx
	sub %dx, %cx # cur_curs
	sub %dx, %di
	sub %dx, %di

	pop %dx # [s.l1:num]
	pop %bx # [s.l0:_vga_size]
	inc %si
	dec %dx # num
	jmp 10b

21: # lf
	mov (VGA_ADDR_COL), %ax
	add %ax, %cx
	add %ax, %di
	add %ax, %di

	# (cur_curs >= _vga_size) ? {shu} : {lp}
	mov (_vga_size), %ax
	cmp %ax, %cx
	jge 31f
	inc %si
	dec %dx # len
	jmp 10b

30: # shu in
	push %ax # [s.l0:chr]

	call _vga_shu

	mov (_vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	jmp 11b

31: # shu
	push %dx # [s.l1:num]

	push %cx
	call _vga_shu
	pop %cx

	# { set curs pos
	mov (VGA_ADDR_COL), %ax
	sub %ax, %cx
	mov %cx, %dx # curs_pos

	mov %dx, %cx # curs_pos
	mov %dx, %di
	add %dx, %di
	# }

	pop %dx # [s.l1:num]

	inc %si
	dec %dx # num
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

# vga_shu()
vga_shu:
	push %es
	push %si
	push %di

	#mov (disp_idx), %ax
	#test %ax, %ax
	#jz 99f

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	mov %di, %si

	call _vga_save_top

	# { disp shift up
	mov (VGA_ADDR_COL), %ax
	mov %ax, %si
	add %ax, %si

	mov (_vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]
	# }

	# clr last line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	# { load bottom
	mov (_vga_last_row_off), %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	mov $disp_bottom_buf, %si
	mov (VGA_ADDR_COL), %cx
	xor %dx, %dx
	mul %cx
	add %ax, %si

	push %si
	push %cx
	call vga_outns
	add $0x04, %sp
	# }

	# upd idx
	mov (disp_idx), %ax
	dec %ax
	mov %ax, (disp_idx)

99:
	pop %di
	pop %si
	pop %es
	ret

# vga_shd()
vga_shd:
	push %es
	push %si
	push %di

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	mov %di, %si

	#mov (disp_idx), %ax
	#cmp $VGA_SCROLL_CNT, %ax
	#je 99f

	# { save bottom
	mov (_vga_last_row_off), %ax
	mov %ax, %si
	add %ax, %si

	mov $disp_bottom_buf, %di
	mov (VGA_ADDR_COL), %cx
	xor %dx, %dx
	mul %cx
	add %ax, %di

1:
	# (column == 0) ? {end}
	mov %es:(%si), %ax
	test %cx, %cx
	jz 2f

	mov %al, (%di)

	add $0x02, %si
	inc %di
	dec %cx
	jmp 1b

2:
	# }

	# { disp shift down
	mov (_vga_last_row_off), %cx
	mov %cx, %si
	add %cx, %si
	sub $0x02, %si # (x[last], y[last-1])

	mov (_vga_size), %ax
	mov %ax, %di
	add %ax, %di
	sub $0x02, %di # (x[last], y[last])

	std
	mov $(VGA_MEM>>0x10), %ax
	push %ds # [s.s0:vga_seg]
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]
	cld
	# }

	# clr first line
	xor %di, %di
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	call _vga_load_top

	# upd idx
	mov (disp_idx), %ax
	inc %ax
	mov %ax, (disp_idx)

99:
	pop %di
	pop %si
	pop %es
	ret

# _vga_shu()
_vga_shu:
	push %es
	push %si
	push %di

	# init
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	mov %di, %si

	call _vga_save_top

	# init
	mov (VGA_ADDR_COL), %ax
	add %ax, %si
	add %ax, %si

	# shift up
	mov (_vga_last_row_off), %cx
	push %ds # [s.r0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.r0:vga_seg]

	# clr last line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	pop %di
	pop %si
	pop %es
	ret

# _vga_save_top()
_vga_save_top:
	push %es
	push %si
	push %di
	push %bx

	# { path
	push $_path_top # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == neq_last) ? {create}
	cmp $0x02, %ax
	je 10f
	# (path_parse() != done) ? {done} : {save}
	test %ax, %ax
	jnz 99f
	jmp 11f # save
	# }

10: # file create
	push $F_TYPE_FILE # (f_type)
	push $_path_top # (&name)
	call fs_add
	add $0x04, %sp

	push $_path_top # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	jmp 11f # save

11: # file save
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov (_top_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 20f
	jmp 30f

20: # circular
	# init
	mov %bx, %si
	mov %si, %di
	mov (VGA_ADDR_COL), %ax
	add %ax, %si
	xor %dx, %dx
	mov $(VGA_SCROLL_CNT-0x01), %cx
	mul %cx
	mov %ax, %cx

21:
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 29f

	# cpy
	mov %es:(%si), %al
	mov %al, %es:(%di)

	inc %si
	inc %di
	dec %cx
	jmp 21b

29:
	# upd size
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	mov (VGA_ADDR_COL), %cx
	sub %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)
	jmp 30f

30: # append
	# init
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %ax, %bx

	push %es # [s.0:mem_seg]
	mov $(VGA_MEM&0xFFFF), %si
	mov (VGA_ADDR_COL), %cx

31: # append
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 39f

	# cpy
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov %es:(%si), %ax
	pop %es # [s.0:mem_seg]
	mov %al, %es:(%bx)
	push %es # [s.0:mem_seg]

	add $0x02, %si
	inc %bx
	dec %cx
	jmp 31b

39:
	pop %es # [s.0:mem_seg]

	push $fsp+FSP_OFF_BASE
	call disk_write_fsp
	add $0x02, %sp

	# upd file size
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	mov (VGA_ADDR_COL), %cx
	add %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)
	push %si
	call fsp_write
	add $0x02, %sp

	# upd cnt
	mov (_top_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 99f
	inc %ax
	mov %ax, (_top_cnt)
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# _vga_load_top()
_vga_load_top:
	push %es
	push %si
	push %di
	push %bx

	# { path
	push $_path_top # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == done) ? {load} : {done}
	test %ax, %ax
	jz 10f
	jmp 99f
	# }

10: # load
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# { calc off
	mov (_top_cnt), %ax
	test %ax, %ax
	jz 99f

	dec %ax
	mov (VGA_ADDR_COL), %cx
	xor %dx, %dx
	mul %cx

	# set off
	add %ax, %bx
	# }

	# init
	push %es # [s.0: file_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	mov $VGA_ATTR_COLOR, %ah

11:
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 19f

	# cpy
	pop %es # [s.0: file_seg]
	mov %es:(%bx), %al
	push %es # [s.0: file_seg]
	mov $(VGA_MEM>>0x10), %dx
	mov %dx, %es
	mov %ax, %es:(%di)

	add $0x02, %di
	inc %bx
	dec %cx
	jmp 11b

19:
	pop %es # [s.0: file_seg]

	# upd file size
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %cx
	mov (VGA_ADDR_COL), %ax
	sub %ax, %cx
	mov %cx, FSP_OFF_F_SIZE(%si)
	push %si
	call fsp_write
	add $0x02, %sp

	# TODO: cursor

	# upd top cnt
	mov (_top_cnt), %ax
	dec %ax
	mov %ax, (_top_cnt)

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_vga_size: .word 0x00
_vga_last_row_off: .word 0x00
_top_cnt: .word 0x00
_bottom_cnt: .word 0x00
_path_top: .asciz "/.top"
_path_bottom: .asciz "/.bottom"
_name_top: .asciz ".top"
_name_bottom: .asciz ".bottom"
