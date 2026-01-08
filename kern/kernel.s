# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/ps2.inc"
.section .text
.code16
.global kern_run
.global mem_alloc
.global mem_free

# kern_run()
kern_run:
	cli
	call pic_init
	call ivt_init
	call vga_init

	call ata_init
	call ps2_init
	call rtc_init
	call rtc_get
	sti

	xor %ax, %ax
	mov %ax, (init_flag)

	call sb_run

	push $_kmsg_welcome
	call vga_outs
	add $0x02, %sp

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	call cwd_init
	call ps1_build

	push $ps1
	call vga_outs
	add $0x02, %sp

	call vga_init_curs
	mov $cl_sbuf, %si
	add $0x02, %si
	jmp 1f

# <req> (*si == cl_sbuf.data)
1: # main loop
	# (chr == null) ? {pass} : {kbd_run}
	mov (scancode), %al
	test %al, %al
	jz 2f

	call kbd_run

2: # wait
	hlt
	jmp 1b

# mem_alloc()
# <ret: [dx:ax] = [seg:off]>
# <mod: mem_bm>
mem_alloc:
	push %si

	mov $mem_bm, %si
	inc %si # skip 0x0000 segment

	xor %cx, %cx # bit cnt
	xor %dx, %dx # byte cnt
	inc %dx

1: # byte cnt
	# (byte != full) ? {next} : {lp}
	mov (%si), %al
	cmp $0xFF, %al
	jne 2f

	inc %si
	inc %dx
	jmp 1b

2: # bit cnt init
	xor %cx, %cx # bit cnt
	push %dx # [s.l0:byte_cnt]

3: # bit cnt
	mov $(0x01<<0x00), %dl
	shl %cl, %dl

	# (bit != set) ? {end} : {lp}
	test %dl, %al
	jz 90f

	inc %cx
	jmp 3b

90:
	or %dl, %al # set
	pop %dx # [s.l0:byte_cnt]

	mov %al, (%si)
	mov %cx, %ax

	shl $0x0C, %dx # <ret:seg>
	shl $0x0C, %ax # <ret:off>

	pop %si
	ret

# mem_free(ub16 *seg, ub16 *off)
# <mod: mem_bm>
mem_free:
	push %bp
	mov %sp, %bp
	push %si

	mov $mem_bm, %si

	# seg
	mov 0x04(%bp), %ax
	shr $0x0C, %ax
	add %ax, %si

	xor %ax, %ax
	mov (%si), %al

	# off
	mov 0x06(%bp), %cx
	shr $0x0C, %cx

	mov (0x01<<0x00), %dl
	shl %cl, %dl
	not %dl
	and %dl, %al

	mov %al, (%si)

	pop %si
	pop %bp
	ret

.section .data
.global cl_sbuf
.global cl_hist_sbuf
.global tmp_sbuf
.global redir_hsbuf
.global write_sbuf

.global scancode
.global init_flag
.global rtc_tick
.global rtc_date
.global mem_bm
.global curs

cl_sbuf: .zero 0x200
cl_hist_sbuf: .zero 0x200
tmp_sbuf: .zero 0x200
redir_hsbuf: .zero 0x200
write_sbuf: .zero 0x200

scancode: .word 0x00
init_flag: .word 0x01
rtc_tick: .word 0x00
rtc_date: .zero 0x07
mem_bm: .zero 0x20
curs:
	.word 0x00 # min_pos
	.word 0x00 # max_pos

_kmsg_welcome: .asciz "\r\nWelcome to Fayos\r\n"
