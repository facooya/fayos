# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Load memory for immutable disk packet

.include "drv/disk.s"
.section .text
.code16
.global disk_load_dpi

# disk_load_dpi()
disk_load_dpi:
	push %bx

	mov $dpi, %bx
	mov $0x04, %cx
	# [sb, bbm, ibm, it]

.lp:
	test %cx, %cx
	jz .done

	push %cx # [s.f0:cnt]
	push %bx
	call disk_read_dp
	add $0x02, %sp
	pop %cx # [s.f0:cnt]

	add $DP_SIZE, %bx
	dec %cx
	jmp .lp

.done:
	pop %bx
	ret
