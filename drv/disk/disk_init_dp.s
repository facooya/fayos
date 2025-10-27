# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Initial

.include "fs/ind.s"
.include "drv/disk.s"
.section .text
.code16
.global disk_init_dp

# disk_init_dp()
# <req> indp
disk_init_dp:
	push %si
	push %di

	mov $indp, %si
	mov $dp, %di
	mov $0x05, %cx
	# [par, cur, tmp, root, path]

.lp:
	test %cx, %cx
	jz .done

	# set sect cnt
	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	# set mem
	mov $(DISK_PAR_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_PAR_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	# { set lba
	push %cx # [s.f0:cnt]
	push IND_OFF_BLK_0(%si)
	push IND_OFF_BLK_0+0x02(%si)
	call fs_blk_to_lba
	add $0x04, %sp
	pop %cx # [s.f0:cnt]

	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)
	# }

	add $DP_SIZE, %di
	add $INDP_SIZE, %si
	dec %cx
	jmp .lp

.done:
	pop %di
	pop %si
	ret
