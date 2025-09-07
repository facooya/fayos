# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read kernel disk for boot

# read_kernel()
read_kernel:
	# set mode
	mov $0x01F6, %dx
	mov $0xE0, %al # 0b11100000
	out %al, %dx

	# sector count
	mov $0x01F2, %dx
	mov $KERNEL_SECTOR_CNT, %al
	mov $KERNEL_SECTOR_CNT, %bx
	out %al, %dx

	# {{{ LBA
	mov $0x01F3, %dx
	mov $KERNEL_LBA_LOW, %al
	out %al, %dx

	mov $0x01F4, %dx
	mov $KERNEL_LBA_MID, %al
	out %al, %dx

	mov $0x01F5, %dx
	mov $KERNEL_LBA_HIGH, %al
	out %al, %dx
	# }}}

	# read
	mov $0x01F7, %dx
	mov $0x20, %al
	out %al, %dx
	jmp .read_kernel__drq__lp

.read_kernel__sec__lp:
	mov $0x01F7, %dx

.read_kernel__drq__lp:
	in %dx, %al
	test $0x08, %al
	jz .read_kernel__drq__lp

	# TODO: error

	mov $0x01F0, %dx
	mov $SECTOR_SIZE_WORD, %cx
	sub $0x01, %bx # sector count

.read_kernel__data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .read_kernel__data__end

	in %dx, %ax
	mov %ax, %es:(%di)

	# {lp}
	sub $0x01, %cx
	add $0x02, %di
	jmp .read_kernel__data__lp

.read_kernel__data__end:
	# (sector == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz .read_kernel__disk__done
	jmp .read_kernel__sec__lp

.read_kernel__disk__done:
	ret

