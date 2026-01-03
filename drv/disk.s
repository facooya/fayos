# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "drv/disk.inc"
.include "fs/fs.inc"
.include "fs/sb.inc"
.section .text
.code16
.global disk_set_dpi
.global disk_load_dpi
.global disk_read_dpi
.global disk_write_dpi
.global disk_read_fsp
.global disk_write_fsp

# disk_set_dpi()
# <mod> dpi
disk_set_dpi:
	push %es
	push %si
	push %di

	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %si
	add $SB_OFF_DPI_SB, %si
	mov $dpi, %di
	mov $0x04, %cx # dpi_cnt
	# [sb, bbm, ibm, it]

1:
	test %cx, %cx
	jz 99f

	mov %es:DP_OFF_SECT_CNT(%si), %ax
	mov %ax, %es:DP_OFF_SECT_CNT(%di)

	mov %es:DP_OFF_MEM+0x02(%si), %ax
	mov %ax, %es:DP_OFF_MEM(%di)
	mov %es:DP_OFF_MEM(%si), %ax
	mov %ax, %es:DP_OFF_MEM(%di)

	mov %es:DP_OFF_LBA(%si), %ax
	mov %ax, %es:DP_OFF_LBA(%di)

	add $DP_SIZE, %si
	add $DP_SIZE, %di
	dec %cx
	jmp 1b

99:
	pop %di
	pop %si
	pop %es
	ret

# disk_load_dpi()
disk_load_dpi:
	push %bx

	mov $dpi, %bx
	mov $0x04, %cx
	# [sb, bbm, ibm, it]

1:
	test %cx, %cx
	jz 99f

	push %cx # [s.f0:cnt]
	push %bx
	call disk_read_dpi
	add $0x02, %sp
	pop %cx # [s.f0:cnt]

	add $DP_SIZE, %bx
	dec %cx
	jmp 1b

99:
	pop %bx
	ret

# disk_read_dpi(dpi *src)
# <ret> dx:ax = seg:off
disk_read_dpi:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx
	mov DP_OFF_SECT_CNT(%bx), %ax
	push %ax
	mov DP_OFF_LBA(%bx), %ax
	push %ax
	mov DP_OFF_MEM(%bx), %ax
	push %ax
	mov DP_OFF_MEM+0x02(%bx), %ax
	push %ax
	call ata_read_sect
	add $0x08, %sp

	pop %bx
	pop %bp
	ret

# disk_write_dpi(dpi *src)
# <ret> dx:ax = seg:off
disk_write_dpi:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx
	mov DP_OFF_SECT_CNT(%bx), %ax
	push %ax
	mov DP_OFF_LBA(%bx), %ax
	push %ax
	mov DP_OFF_MEM(%bx), %ax
	push %ax
	mov DP_OFF_MEM+0x02(%bx), %ax
	push %ax
	call ata_write_sect
	add $0x08, %sp

	pop %bx
	pop %bp
	ret

# disk_read_fsp(fsp *src)
# <ret> dx:ax = seg:off
disk_read_fsp:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx # (fsp &src)
	mov FSP_OFF_DISK_SECT_CNT(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_LBA(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_MEM(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_MEM+0x02(%bx), %ax
	push %ax
	call ata_read_sect
	add $0x08, %sp

	pop %bx
	pop %bp
	ret

# disk_write_fsp(fsp *src)
# <ret> dx:ax = seg:off
disk_write_fsp:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx # (fsp &src)
	mov FSP_OFF_DISK_SECT_CNT(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_LBA(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_MEM(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_MEM+0x02(%bx), %ax
	push %ax
	call ata_write_sect
	add $0x08, %sp

	pop %bx
	pop %bp
	ret

.section .data
.global dpi
dpi: .zero 0x100
