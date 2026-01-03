# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/ps2.inc"
.include "drv/kbd.inc"
.section .text
.code16
.global kbd_run

# kbd_run()
# <mod: scancode>
kbd_run:
	call _kbd_upd_mflg
	# <mod: _kbd_mflg, scancode>
	# <ax = {skip:0}>

	# (_kbd_upd_mflg() == 0) ? {done}
	test %ax, %ax
	jz 90f

	call _kbd_conv_kc
	# <req: scancode, _kbd_mflg>
	# <al = kc>

	call _kbd_proc
	# <req: al = kc>

90:
	xor %ax, %ax
	mov %ax, (scancode)
	ret

# _kbd_upd_mflg()
# <mod: scancode, _kbd_mflg>
# <ret: ax = {skip:0}>
_kbd_upd_mflg:
	mov (_kbd_mflg), %cx
	mov (scancode), %ax
	mov %ax, %dx

	# (sc == ext) ? {no_ext}
	test $PS2_SCF_EXT, %dh
	jz 1f
	mov $PS2_SC_EXT, %dh
	mov %dh, (scancode+0x01)
	jmp 2f

1: # no extend key
	xor %dh, %dh
	mov %dh, (scancode+0x01)

2:
	# (sc != brk) ? {set} : {clr}
	test $PS2_SCF_BRK, %ah
	jz 10f
	jmp 20f

10: # set
	# (sc == lshf) ? {lshf.set}
	cmp $PS2_SC_LSHF, %dx
	je 11f
	# (sc == rshf) ? {rshf.set}
	cmp $PS2_SC_RSHF, %dx
	je 12f

	# (sc == lctl) ? {lctl.set}
	cmp $PS2_SC_LCTL, %dx
	je 13f
	# (sc == rctl) ? {rctl.set}
	cmp $PS2_SC_RCTL, %dx
	je 14f

	# (sc == lalt) ? {lalt.set}
	cmp $PS2_SC_LALT, %dx
	je 15f
	# (sc == ralt) ? {ralt.set}
	cmp $PS2_SC_RALT, %dx
	je 16f

	# (sc == caps) ? {cap.set}
	cmp $PS2_SC_CAP, %dx
	je 17f
	jmp 99f

20: # clr
	# (sc_brk == lshf) ? {lshf.clr}
	cmp $PS2_SC_LSHF, %dx
	je 21f
	# (sc_brk == rshf) ? {rshf.clr}
	cmp $PS2_SC_RSHF, %dx
	je 22f

	# (sc == lctl) ? {lctl.clr}
	cmp $PS2_SC_LCTL, %dx
	je 23f
	# (sc == rctl) ? {rctl.clr}
	cmp $PS2_SC_RCTL, %dx
	je 24f

	# (sc == lalt) ? {lalt.clr}
	cmp $PS2_SC_LALT, %dx
	je 25f
	# (sc == ralt) ? {ralt.clr}
	cmp $PS2_SC_RALT, %dx
	je 26f

	xor %ax, %ax
	jmp 99f

# lshf
11:
	or $KBD_MFLG_LSHF, %cx
	jmp 91f
21:
	and $~KBD_MFLG_LSHF, %cx
	jmp 91f

# rshf
12:
	or $KBD_MFLG_RSHF, %cx
	jmp 91f
22:
	and $~KBD_MFLG_RSHF, %cx
	jmp 91f

# lctl
13:
	or $KBD_MFLG_LCTL, %cx
	jmp 91f
23:
	and $~KBD_MFLG_LCTL, %cx
	jmp 91f

# rctl
14:
	or $KBD_MFLG_RCTL, %cx
	jmp 91f
24:
	and $~KBD_MFLG_RCTL, %cx
	jmp 91f

# lalt
15:
	or $KBD_MFLG_LALT, %cx
	jmp 91f
25:
	and $~KBD_MFLG_LALT, %cx
	jmp 91f

# ralt
16:
	or $KBD_MFLG_RALT, %cx
	jmp 91f
26:
	and $~KBD_MFLG_RALT, %cx
	jmp 91f

# cap
17:
	test $KBD_MFLG_CAP, %cx
	jnz 27f
	or $KBD_MFLG_CAP, %cx
	jmp 91f
27:
	and $~KBD_MFLG_CAP, %cx
	jmp 91f

91: # flag
	mov %cx, (_kbd_mflg)
	xor %ax, %ax
	jmp 99f

99:
	ret

# _kbd_conv_kc()
# <req: scancode, _kbd_mflg>
# <ret: al = kc>
_kbd_conv_kc:
	push %si

	mov (scancode), %ax

	# (sc != norm) ? {ext}
	test %ah, %ah
	jnz 20f

	mov $_kbd_keymap, %si
	# (mflg == 0) ? {norm}
	mov (_kbd_mflg), %cx
	test %cx, %cx
	jz 2f

	# ((mflg & cap) != 0) ? {cap}
	test $KBD_MFLG_CAP, %cx
	jnz 10f

	# ((mflg & lshf) != 0) ? {shf}
	test $KBD_MFLG_LSHF, %cx
	jnz 1f
	# ((mflg & rshf) != 0) ? {shf}
	test $KBD_MFLG_RSHF, %cx
	jnz 1f
	jmp 2f

1: # shf
	mov $_kbd_keymap_shf, %si

2: # norm
	add %ax, %si
	mov (%si), %al
	jmp 99f

10: # caps
	mov $_kbd_keymap_shf, %si

	# ((mflg & lshf) != 0) ? {cap.shf}
	test $KBD_MFLG_LSHF, %cx
	jnz 11f

	# ((mflg & rshf) != 0) ? {cap.shf}
	test $KBD_MFLG_RSHF, %cx
	jnz 11f

	# get kc
	mov $_kbd_keymap, %si
	add %ax, %si
	mov (%si), %al

	push %ax # [s.0:kc]
	cmp $CHR_LC_A, %al
	jb 2f
	cmp $CHR_LC_Z, %al
	jbe 1f
	pop %ax
	jmp 99f

1: # true
	pop %ax # [s.0:kc]
	sub $CHR_CASE_MASK, %al
	jmp 99f

2: # false
	pop %ax # [s.0:kc]
	jmp 99f

11: # shf
	# get kc
	mov $_kbd_keymap_shf, %si
	add %ax, %si
	mov (%si), %al

	push %ax # [s.0:kc]
	cmp $CHR_UC_A, %al
	jb 2f
	cmp $CHR_UC_Z, %al
	jbe 1f
	pop %ax
	jmp 99f

1: # true
	pop %ax # [s.0:kc]
	add $CHR_CASE_MASK, %al
	jmp 99f

2: # false
	pop %ax # [s.0:kc]
	jmp 99f

20: # extends
	# arrow
	cmp $PS2_SC_UP, %ax
	je 21f
	cmp $PS2_SC_DOWN, %ax
	je 22f
	cmp $PS2_SC_LEFT, %ax
	je 23f
	cmp $PS2_SC_RIGHT, %ax
	je 24f

	# num
	cmp $PS2_SC_NUM_SL, %ax
	je 25f
	cmp $PS2_SC_NUM_ENT, %ax
	je 26f
	jmp 99f

# arrow
21: # up
	xor %ax, %ax
	mov $KBD_KC_UP, %al
	jmp 99f
22: # down
	xor %ax, %ax
	mov $KBD_KC_DOWN, %al
	jmp 99f
23: # left
	xor %ax, %ax
	mov $KBD_KC_LEFT, %al
	jmp 99f
24: # right
	xor %ax, %ax
	mov $KBD_KC_RIGHT, %al
	jmp 99f

# numpad
25: # slash
	xor %ax, %ax
	mov $KBD_KC_NUM_SL, %al
	jmp 99f
26: # enter
	xor %ax, %ax
	mov $KBD_KC_NUM_ENT, %al
	jmp 99f

99:
	pop %si
	ret

# _kbd_proc()
# <req: al = kc>
_kbd_proc:
	# {
	# (kc == bs) ? {key.bs}
	cmp $CHR_BS, %al
	je 22f
	# (kc == cr) ? {key.cr}
	cmp $CHR_CR, %al
	je 21f

	# (kc == tab) ? {key.tab}
	cmp $KBD_KC_TAB, %al
	je 99f
	# (kc == esc) ? {key.esc}
	cmp $KBD_KC_ESC, %al
	je 99f
	# }

	# TODO: check (kc >= 0x80)
	# { arrow
	# (kc == up) ? {key.up}
	cmp $KBD_KC_UP, %al
	je 23f
	# (kc == down) ? {key.down}
	cmp $KBD_KC_DOWN, %al
	je 24f
	# (kc == left) ? {key.left}
	cmp $KBD_KC_LEFT, %al
	je 25f
	# (kc == right) ? {key.right}
	cmp $KBD_KC_RIGHT, %al
	je 26f
	# }

	# { numpad
	# (kc == num_sl) ? {key.n.sl}
	cmp $KBD_KC_NUM_SL, %al
	je 27f
	# (kc == num_ent) ? {key.n.cr}
	cmp $KBD_KC_NUM_ENT, %al
	je 21f
	# }

	# { fn
	# (kc == f1) ? {key.f1}
	cmp $KBD_KC_F1, %al
	je 99f
	# (kc == f2) ? {key.f2}
	cmp $KBD_KC_F2, %al
	je 99f
	# }
	jmp 10f

27: # num slash
	mov $CHR_SL, %al
	jmp 10f

10: # normal
	# { pre-update
	# update cl_sbuf
	push %ax # [s.0:kc]
	inc %si # cl_sbuf.data
	mov (cl_sbuf), %ax # cl.size
	inc %ax
	mov %ax, (cl_sbuf)

	# update curs max
	mov (curs+0x02), %ax # curs.max
	inc %ax
	mov %ax, (curs+0x02)
	pop %ax # [s.0:kc]
	# }

	# (*(cl.data-1) != null) ? {shr.cl}
	mov -0x01(%si), %ah
	test %ah, %ah
	jnz 11f

	# {
	push %ax # [s.f0:kc]
	call vga_outc
	pop %ax # [s.f0:kc]

	# store chr
	mov %al, -0x01(%si) # cl.data
	jmp 99f
	# }

11: # shift right
	xor %ah, %ah
	push %ax
	push %si
	call disp_shr_cl
	add $0x04, %sp
	jmp 99f

21:
	call _kbd_hdl_cr
	jmp 99f
22:
	call _kbd_hdl_bs
	jmp 99f

# arrow
23:
	call _kbd_hdl_up
	jmp 99f
24:
	call _kbd_hdl_down
	jmp 99f
25:
	call _kbd_hdl_left
	jmp 99f
26:
	call _kbd_hdl_right
	jmp 99f

99:
	ret

# _kbd_hdl_cr()
# <mod: cl_sbuf>
# <ret: si = &cl_sbuf.data>
_kbd_hdl_cr:
	call exec_cmd

	push $ps1
	call vga_outs
	add $0x02, %sp

	call vga_init_curs

	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	mov $cl_sbuf, %si
	add $0x02, %si # <ret>
	ret

# _kbd_hdl_bs()
# <mod: cl_sbuf, curs>
# <ret: si = {norm:&cl_sbuf.data+i-1}, {skip:&cl_sbuf.data+i}>
_kbd_hdl_bs:
	# {
	call vga_get_curs
	# <ax = curs_pos>

	# (curs.x == curs.min) ? {done}
	cmp (curs), %ax
	je 99f
	# <ret:skip>
	# }

	# { pre-update
	# dec curs max
	mov (curs+0x02), %ax # curs.max
	dec %ax
	mov %ax, (curs+0x02)

	# dec cl_sbuf
	dec %si # &cl_sbuf.data
	mov (cl_sbuf), %ax # cl_sbuf.size
	dec %ax
	mov %ax, (cl_sbuf)
	# }

	# (*(cl_sbuf+1) != null) ? {shl}
	mov 0x01(%si), %al
	test %al, %al
	jnz 10f

	# {
	# left curs
	call vga_get_curs
	# <ax = curs_pos>
	dec %ax
	push %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# overwrite
	mov $CHR_SP, %al # space
	call vga_outc

	# left curs
	pop %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# store null
	xor %al, %al
	mov %al, (%si) # <ret>
	# }
	jmp 99f

10:
	push %si
	call disp_shl_cl
	add $0x02, %sp
	jmp 99f

99:
	ret

# _kbd_hdl_up()
# <req: file_lines>
# <mod: cl_sbuf, cl_hist_sbuf, hist_idx>
# <ret: si = &cl_sbuf.data+last_i>
_kbd_hdl_up:
	# (hist_idx == 0) ? {done}
	mov (hist_idx), %ax
	test %ax, %ax
	jz 99f

	# (hist_idx == line_count) ? {save} : {pass}
	mov (file_lines), %cx
	cmp %cx, %ax
	je 10f
	dec %ax
	mov %ax, (hist_idx)
	jmp 20f

10: # save
	dec %ax
	mov %ax, (hist_idx)

	# (size == 0) ? {pass}
	mov (cl_sbuf), %ax
	test %ax, %ax
	jz 20f

	# zero
	xor %ax, %ax
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	# cpy
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push $cl_sbuf # (*s_off)
	push %ax # (*s_seg)
	push $cl_hist_sbuf # (*d_off)
	push %ax # (*d_seg)
	call mem_cpy
	add $0x0A, %sp

20: # pass
	call hist_upd_cl
	# <ax = cl_pos>
	mov %ax, %si # <ret>
	jmp 99f

99:
	ret

# _kbd_hdl_down()
# <req: cl_hist_sbuf, file_lines>
# <mod: cl_sbuf, hist_idx>
# <ret: si = &cl_sbuf.data+last_i>
_kbd_hdl_down:
	# upd hist_idx
	mov (hist_idx), %ax
	mov (file_lines), %cx

	# (hist_idx == line_count) ? {done}
	cmp %cx, %ax
	je 99f

	inc %ax
	mov %ax, (hist_idx)

	# (hist_idx++ == line_count) ? {load} : {pass}
	cmp %cx, %ax
	je 10f
	jmp 20f

10: # load
	# zero
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	# cpy
	xor %ax, %ax
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push $cl_hist_sbuf # (&s_off)
	push %ax # (&s_seg)
	push $cl_sbuf # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	call vga_clr_line

	push $ps1
	call vga_outs
	add $0x02, %sp

	call vga_init_curs

	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:size]
	push %si
	push %cx
	call vga_outns
	add $0x04, %sp
	pop %cx # [s.f0:size]
	add %cx, %si

	mov (curs), %ax
	add %ax, %cx
	mov %cx, (curs+0x02)
	jmp 99f

20: # pass
	call hist_upd_cl
	# <ax = cl_pos>
	mov %ax, %si # <ret>
	jmp 99f

99:
	ret

# _kbd_hdl_left()
# <req: si = &cl_sbuf+i>
# <req: curs>
# <ret: si = {norm:&cl_sbuf+i-1}, {skip:&cl_sbuf+i}>
_kbd_hdl_left:
	call vga_get_curs

	# (curs.x == curs.min) ? {done}
	cmp (curs), %ax
	je 99f

	# left curs
	dec %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	dec %si # <ret>

99:
	ret

# _kbd_hdl_right()
# <req: si = cl_sbuf+i>
# <req: curs>
# <ret: si = {norm:&cl_sbuf+i+1}, {skip:&cl_sbuf+i}>
_kbd_hdl_right:
	call vga_get_curs

	# (curs.x == curs.max) ? {done}
	cmp (curs+0x02), %ax
	je 99f

	# right curs
	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	inc %si # <ret>

99:
	ret

.section .data
_kbd_mflg: .word 0x00
_kbd_keymap:
	# 0x00-0x0F
	.byte 0x00, 0xF9, 0x00, 0xF5, 0xF3, 0xF1, 0xF2, 0xFC
	.byte 0x00, 0xFA, 0xF8, 0xF6, 0xF4, 0xFE, 0x60, 0x00

	# 0x10-0x1F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x31, 0x00
	.byte 0x00, 0x00, 0x7A, 0x73, 0x61, 0x77, 0x32, 0x00

	# 0x20-0x2F
	.byte 0x00, 0x63, 0x78, 0x64, 0x65, 0x34, 0x33, 0x00
	.byte 0x00, 0x20, 0x76, 0x66, 0x74, 0x72, 0x35, 0x00

	# 0x30-0x3F
	.byte 0x00, 0x6E, 0x62, 0x68, 0x67, 0x79, 0x36, 0x00
	.byte 0x00, 0x00, 0x6D, 0x6A, 0x75, 0x37, 0x38, 0x00

	# 0x40-0x4F
	.byte 0x00, 0x2C, 0x6B, 0x69, 0x6F, 0x30, 0x39, 0x00
	.byte 0x00, 0x2E, 0x2F, 0x6C, 0x3B, 0x70, 0x2D, 0x00

	# 0x50-0x5F
	.byte 0x00, 0x00, 0x27, 0x00, 0x5B, 0x3D, 0x00, 0x00
	.byte 0x00, 0x00, 0x0D, 0x5D, 0x00, 0x5C, 0x00, 0x00

	# 0x60-0x6F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00
	.byte 0x00, 0x31, 0x00, 0x34, 0x37, 0x00, 0x00, 0x00

	# 0x70-0x7F
	.byte 0x30, 0x2E, 0x32, 0x35, 0x36, 0x38, 0xFF, 0x00
	.byte 0xFB, 0x2B, 0x33, 0x2D, 0x2A, 0x39, 0x00, 0x00

	# 0x80-0x8F
	.byte 0x00, 0x00, 0x00, 0xF7, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

_kbd_keymap_shf:
	# 0x00-0x0F
	.byte 0x00, 0xF9, 0x00, 0xF5, 0xF3, 0xF1, 0xF2, 0xFC
	.byte 0x00, 0xFA, 0xF8, 0xF6, 0xF4, 0xFE, 0x7E, 0x00

	# 0x10-0x1F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x21, 0x00
	.byte 0x00, 0x00, 0x5A, 0x53, 0x41, 0x57, 0x40, 0x00

	# 0x20-0x2F
	.byte 0x00, 0x43, 0x58, 0x44, 0x45, 0x24, 0x23, 0x00
	.byte 0x00, 0x20, 0x56, 0x46, 0x54, 0x52, 0x25, 0x00

	# 0x30-0x3F
	.byte 0x00, 0x4E, 0x42, 0x48, 0x47, 0x59, 0x5E, 0x00
	.byte 0x00, 0x00, 0x4D, 0x4A, 0x55, 0x26, 0x2A, 0x00

	# 0x40-0x4F
	.byte 0x00, 0x3C, 0x4B, 0x49, 0x4F, 0x29, 0x28, 0x00
	.byte 0x00, 0x3E, 0x3F, 0x4C, 0x3A, 0x50, 0x5F, 0x00

	# 0x50-0x5F
	.byte 0x00, 0x00, 0x22, 0x00, 0x7B, 0x2B, 0x00, 0x00
	.byte 0x00, 0x00, 0x0D, 0x7D, 0x00, 0x7C, 0x00, 0x00

	# 0x60-0x6F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00
	.byte 0x00, 0x31, 0x00, 0x34, 0x37, 0x00, 0x00, 0x00

	# 0x70-0x7F
	.byte 0x30, 0x2E, 0x32, 0x35, 0x36, 0x38, 0xFF, 0x00
	.byte 0xFB, 0x2B, 0x33, 0x2D, 0x2A, 0x39, 0x00, 0x00

	# 0x80-0x8F
	.byte 0x00, 0x00, 0x00, 0xF7, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
