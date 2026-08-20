# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "boot.inc"
.section .text
.code16
.global _start

# _start()
_start:
	# init
	cli
	cld
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov %ax, %sp
	mov %ax, %bp

	# set stack
	mov $STACK_PTR, %sp

	# display
	call _vga_init_row_col
	call _vga_clr
	push $_bmsg_fayos
	call _vga_outs
	add $0x02, %sp

	# kernel
	mov $(KERN_MEM&0xFFFF), %di
	call _ata_read
	ljmp $(KERN_MEM>>0x10), $(KERN_MEM&0xFFFF)

# _vga_init_row_col()
# <mod: _vga_row, _vga_col>
_vga_init_row_col:
	push %bx

	# { get columns
	mov $VGA_PORT_CRTC_CMD, %dx
	mov $VGA_CMD_COL, %al
	out %al, %dx

	mov $VGA_PORT_CRTC_DATA, %dx
	in %dx, %al
	xor %ah, %ah
	inc %ax

	mov %ax, (_vga_col)
	# }

	# {{ get rows
	# { char height
	mov $VGA_PORT_CRTC_CMD, %dx
	mov $VGA_CMD_CHR_H, %al
	out %al, %dx

	mov $VGA_PORT_CRTC_DATA, %dx
	in %dx, %al
	and $VGA_MASK_CHR_H, %al
	inc %al

	xor %bx, %bx
	mov %al, %bl
	# <bx=char_height>
	# }

	# { full height low
	mov $VGA_PORT_CRTC_CMD, %dx
	mov $VGA_CMD_ROW_LO, %al
	out %al, %dx
	
	mov $VGA_PORT_CRTC_DATA, %dx
	in %dx, %al

	xor %cx, %cx
	mov %al, %cl
	# <cl=full_height_lo>
	# }

	# { full height high
	mov $VGA_PORT_CRTC_CMD, %dx
	mov $VGA_CMD_ROW_HI, %al
	out %al, %dx

	mov $VGA_PORT_CRTC_DATA, %dx
	in %dx, %al

	test $VGA_ROW_HI_8, %al
	jz 1f
	or $(0x01<<0x00), %ch
	# <ch=full_height_hi>

1:
	test $VGA_ROW_HI_9, %al
	jz 2f
	or $(0x01<<0x01), %ch
	# <ch=full_height_hi>
	# }

2:
	inc %cx
	# <cx=full_height>

	# (full_height / char_height = rows)
	xor %dx, %dx
	mov %cx, %ax
	div %bx
	xor %ah, %ah
	# <ax = rows>
	mov %ax, (_vga_row)
	# }}

	pop %bx
	ret

# _vga_clr()
_vga_clr:
	push %es

	# init
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	# get size
	mov (_vga_row), %dx
	mov (_vga_col), %cx

	mul %dx
	mov %ax, %cx

1:
	# (count == 0) ? {end}
	test %cx, %cx
	jz 9f

	# clear
	mov $CHR_SP, %al
	mov %al, %es:(%di)
	inc %di

	# attr
	mov $VGA_ATTR_COLOR, %al
	mov %al, %es:(%di)
	inc %di

	dec %cx
	jmp 1b

9:
	# { set curs
	mov $VGA_CMD_CURS_POS_HI, %al
	mov $VGA_PORT_CRTC_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CRTC_DATA, %dx
	xor %al, %al
	out %al, %dx

	mov $VGA_CMD_CURS_POS_LO, %al
	mov $VGA_PORT_CRTC_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CRTC_DATA, %dx
	xor %al, %al
	out %al, %dx
	# }

	pop %es
	ret

# _vga_outs(ub8 *str)
_vga_outs:
	push %bp
	mov %sp, %bp
	push %es

	mov 0x04(%bp), %si # (*str)

	# init
	mov (_vga_col), %cx

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di
	add %cx, %di
	add %cx, %di

	# { get curs
	mov $VGA_CMD_CURS_POS_HI, %al
	mov $VGA_PORT_CRTC_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CRTC_DATA, %dx
	in %dx, %al
	mov %al, %ah

	mov $VGA_CMD_CURS_POS_LO, %al
	mov $VGA_PORT_CRTC_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CRTC_DATA, %dx
	in %dx, %al

	# skip outc, conf
	add %ax, %di
	add %ax, %di

	mov %ax, %cx # pos
	# }

1:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz 9f

	# (chr == newline) ? {newline}
	cmp $CHR_NL, %al
	je 2f

	# out
	mov %al, %es:(%di)
	inc %di

	# attr
	mov $VGA_ATTR_COLOR, %al
	mov %al, %es:(%di)
	inc %di

	inc %si
	inc %cx # pos
	jmp 1b

2: # newline
	# { newline
	push %cx
	mov (_vga_col), %cx

	xor %dx, %dx
	mov %di, %ax
	div %cx
	sub %dx, %di # init col

	# skip out, conf
	add %cx, %di
	add %cx, %di

	pop %cx
	# }

	# curs pos
	mov %di, %ax
	mov $0x02, %cx
	xor %dx, %dx
	div %cx
	mov %ax, %cx

	inc %si
	jmp 1b

9:
	# { set curs
	mov $VGA_CMD_CURS_POS_HI, %al
	mov $VGA_PORT_CRTC_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CRTC_DATA, %dx
	mov %ch, %al
	out %al, %dx

	mov $VGA_CMD_CURS_POS_LO, %al
	mov $VGA_PORT_CRTC_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CRTC_DATA, %dx
	mov %cl, %al
	out %al, %dx
	# }

	pop %es
	pop %bp
	ret

# _ata_read()
_ata_read:
	push %es
	push %di

	# set mode
	mov $ATA_PORT_DRV, %dx
	mov $ATA_DRV_MA_LBA, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	# sector count
	mov $ATA_PORT_SECT_CNT, %dx
	mov $KERN_SECT_CNT, %al
	mov $KERN_SECT_CNT, %bx
	out %al, %dx

	# { lba
	mov $ATA_PORT_LBA_LO, %dx
	mov $KERN_LBA, %ax
	out %al, %dx

	mov $ATA_PORT_LBA_MID, %dx
	mov %ah, %al
	out %al, %dx

	mov $ATA_PORT_LBA_HI, %dx
	xor %ax, %ax
	out %al, %dx
	# }

	# read
	mov $ATA_PORT_CMD, %dx
	mov $ATA_CMD_READ, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	mov $(KERN_MEM>>0x10), %ax
	mov %ax, %es
	mov $(KERN_MEM&0xFFFF), %di
	jmp 2f

1:
	mov $ATA_PORT_STAT, %dx

2:
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz 2b

	# TODO: error

	mov $ATA_PORT_DATA, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	sub $0x01, %bx # sector count

3:
	# (count == 0) ? {end}
	test %cx, %cx
	jz 9f

	# load
	in %dx, %ax
	mov %ax, %es:(%di)

	sub $0x01, %cx
	add $0x02, %di
	jmp 3b

9:
	# (sector == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz 99f
	jmp 1b

99:
	pop %di
	pop %es
	ret

.section .rodata
_bmsg_fayos: .asciz "FAYOS\n"

.section .data
_vga_row: .word 0x00
_vga_col: .word 0x00
