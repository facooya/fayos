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
.global vga_show_curs
.global vga_hide_curs
.global vga_outc
.global vga_outs
.global vga_outns
.global vga_shu
.global vga_shd

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
	push $0x00 # (flag)
	call vga_show_curs
	add $0x02, %sp
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

# vga_show_curs(ub16 flag)
# (flag = {0: norm, block})
vga_show_curs:
	push %bp
	mov %sp, %bp

	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_START, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov $VGA_CURS_START_LINE, %al

	# (flag == norm) ? {skip}
	mov 0x04(%bp), %cx
	test %cx, %cx
	jz 1f
	mov $VGA_CURS_BLOCK_START_LINE, %al

1:
	out %al, %dx

	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_END, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov $VGA_CURS_END_LINE, %al
	out %al, %dx

	pop %bp
	ret

# vga_hide_curs()
vga_hide_curs:
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_START, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov $VGA_CURS_DISABLE, %al
	out %al, %dx
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
	push $0x00
	call vga_shu
	add $0x02, %sp

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

	push $0x00
	call vga_shu
	add $0x02, %sp

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

# vga_outs(ub8 *str)
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

	push $0x00
	call vga_shu
	add $0x02, %sp

	# set curs pos
	mov (_vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	jmp 11b

31: # shu
	push %cx # [s.f0:curs_pos]
	push $0x00
	call vga_shu
	add $0x02, %sp
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

	push $0x00
	call vga_shu
	add $0x02, %sp

	mov (_vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	jmp 11b

31: # shu
	push %dx # [s.l1:num]

	push %cx
	push $0x00
	call vga_shu
	add $0x02, %sp
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

# vga_shu(ub16 flag)
# (flag = [bit:clr/set] = {0:auto/manual}
# <req: _vga_last_row_off>
# <mod: _vga_cnt>
vga_shu:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	# (flag == auto) ? {pass} : {chk}
	mov 0x04(%bp), %ax
	test $(0x01<<0x00), %ax
	jz 1f

	# (cnt == max) ? {done}
	mov (_vga_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 99f

1:
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	mov %di, %si

	push $0x00 # (flag)
	call _vga_sl_tb
	add $0x02, %sp

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

	# (flag == auto) ? {pass} : {load}
	mov 0x04(%bp), %ax
	test $(0x01<<0x00), %ax
	jz 1f

	push $0x03 # (flag)
	call _vga_sl_tb
	add $0x02, %sp

1:
	# (cnt == max) ? {done} : {cnt++}
	mov (_vga_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 99f
	inc %ax
	mov %ax, (_vga_cnt)

99:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# vga_shd()
# <req: _vga_size, _vga_last_row_off>
# <mod: _vga_cnt>
vga_shd:
	push %es
	push %si
	push %di

	# (cnt == 0) ? {done}
	mov (_vga_cnt), %ax
	test %ax, %ax
	je 99f

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	mov %di, %si

	push $0x02
	call _vga_sl_tb
	add $0x02, %sp

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

	push $0x01
	call _vga_sl_tb
	add $0x02, %sp

	# upd cnt
	mov (_vga_cnt), %ax
	dec %ax
	mov %ax, (_vga_cnt)

99:
	pop %di
	pop %si
	pop %es
	ret

# _vga_sl_tb(ub16 flag)
# (flag = [bit:clr/set] = {0:save/load, 1:top/bottom})
# <req: _path_top, _path_bottom, _name_top, _name_bottom, _vga_last_row_off>
# <mod: vga_top_cnt, vga_bottom_cnt>
_vga_sl_tb:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# { path
	mov $_path_top, %si

	# (flag == top) ? {top} : {bottom}
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jz 1f
	mov $_path_bottom, %si

1:
	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == neq_last) ? {create}
	cmp $0x02, %ax
	je 10f # create
	# (path_parse() != done) ? {err} : {save}
	test %ax, %ax
	jnz 99f
	# TODO: scroll error log
	# }

	# (flag == save) ? {chk} : {load}
	mov 0x04(%bp), %ax
	test $(0x01<<0x00), %ax
	jz 11f
	jmp 30f

10: # create
	mov $_name_top, %di

	# (flag == top) ? {top} : {bottom}
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jz 1f
	mov $_name_bottom, %di

1:
	push $F_TYPE_FILE # (f_type)
	push %di # (&name)
	call fs_add
	add $0x04, %sp

	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>
	jmp 20f

11: # chk
	# (flag != top) ? {save}
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jnz 20f

	# (top_cnt == max) ? {circular} : {save}
	mov (vga_top_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 40f
	jmp 20f

40: # circular for top
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# init
	mov %bx, %si
	mov %si, %di
	mov (VGA_ADDR_COL), %ax
	add %ax, %si
	xor %dx, %dx
	mov $(VGA_SCROLL_CNT-0x01), %cx
	mul %cx
	mov %ax, %cx

41:
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 49f

	# line[i] -> line[i+1]
	mov %es:(%si), %al
	mov %al, %es:(%di)

	inc %si
	inc %di
	dec %cx
	jmp 41b

49:
	# upd size
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	mov (VGA_ADDR_COL), %cx
	sub %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)
	jmp 21f

20: # save
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

21:
	# init
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %ax, %bx

	push %es # [s.0: mem_seg]
	mov $(VGA_MEM&0xFFFF), %si
	mov (VGA_ADDR_COL), %cx

	# (flag == top) ? {loop} : {bottom}
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jz 22f

	# init bottom
	mov (_vga_last_row_off), %ax
	add %ax, %si
	add %ax, %si

22: # top/bottom
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 29f

	# screen -> file
	push %es # [s.1: mem_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov %es:(%si), %ax
	pop %es # [s.1: mem_seg]
	mov %al, %es:(%bx)

	add $0x02, %si
	inc %bx
	dec %cx
	jmp 22b

29:
	pop %es # [s.0: mem_seg]

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

	# { upd cnt
	# (flag == top) ? {top} : {bottom}
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jz 1f
	jmp 2f

1: # top cnt
	mov (vga_top_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 99f
	inc %ax
	mov %ax, (vga_top_cnt)
	jmp 99f

2: # bottom cnt
	mov (vga_bottom_cnt), %ax
	cmp $VGA_SCROLL_CNT, %ax
	je 99f
	inc %ax
	mov %ax, (vga_bottom_cnt)
	jmp 99f
	# }

30: # load
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# (flag == top) ? {top} : {bottom}
	mov $vga_top_cnt, %si
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jz 1f
	mov $vga_bottom_cnt, %si

1:
	# { calc off
	mov (%si), %ax
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
	mov $(VGA_MEM&0xFFFF), %di
	mov $VGA_ATTR_COLOR, %ah

	# (flag == top) ? {loop} : {bottom}
	mov 0x04(%bp), %dx
	test $(0x01<<0x01), %dx
	jz 31f

	# init bottom
	mov (_vga_last_row_off), %dx
	add %dx, %di
	add %dx, %di

31: # top/bottom
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 39f

	# file -> screen
	mov %es:(%bx), %al
	push %es # [s.1: file_seg]
	mov $(VGA_MEM>>0x10), %dx
	mov %dx, %es
	mov %ax, %es:(%di)
	pop %es # [s.1: file_seg]

	add $0x02, %di
	inc %bx
	dec %cx
	jmp 31b

39:
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

	# (flag == top) ? {top} : {bottom}
	mov $vga_top_cnt, %si
	mov 0x04(%bp), %ax
	test $(0x01<<0x01), %ax
	jz 1f
	mov $vga_bottom_cnt, %si

1:
	mov (%si), %ax
	dec %ax
	mov %ax, (%si)

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

.section .data
.global vga_top_cnt
.global vga_bottom_cnt

vga_top_cnt: .word 0x00
vga_bottom_cnt: .word 0x00

_vga_size: .word 0x00
_vga_last_row_off: .word 0x00
_vga_cnt: .word 0x00
_path_top: .asciz "/.top"
_path_bottom: .asciz "/.bottom"
_name_top: .asciz ".top"
_name_bottom: .asciz ".bottom"
