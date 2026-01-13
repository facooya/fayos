# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si

	#push $_path_top # (&path)
	#call dbg_file
	#add $0x02, %sp

	push $_test_data # (data_off)
	xor %ax, %ax
	push %ax # (data_seg)
	push $0x0B # (data_size)
	push $0x00 # (file_curs_pos)
	push $_test_file # (&file_path)
	call file_write_pos
	add $0x0A, %sp

	push $_test_data2 # (data_off)
	xor %ax, %ax
	push %ax # (data_seg)
	push $0x04 # (data_size)
	push $0x05 # (file_curs_pos)
	push $_test_file # (&file_path)
	call file_write_pos
	add $0x0A, %sp

	pop %si
	ret

.section .data
_path_top: .asciz "/.top"
_test_data: .asciz "test data\r\n"
_test_data2: .asciz "AAAA"
_test_file: .asciz "/test"
