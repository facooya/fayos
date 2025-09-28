# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .data
.blknum: .long 0x01

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	mov $0x01, %cx

.lp:
	test %cx, %cx
	jz .done

	push %cx
	mov $0x08, %ax
	push %ax # sect_cnt
	mov $0x01, %ax
	push %ax # lba_lo
	xor %ax, %ax
	push %ax # lba_hi
	push $0x00 # off
	push $0x1000 # seg
	call ata_write_sect
	add $0x0A, %sp
	pop %cx

	sub $0x01, %cx
	jmp .lp

.done:
	call dbg_a
	ret
