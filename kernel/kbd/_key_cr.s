# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key carriage return

.section .text
.code16
.global _key_cr

# _key_cr
_key_cr:
	call exec_cmd

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs

	# {init.task}
	push $raw_buf
	call bufzero
	add $0x02, %sp

	mov $raw_buf, %si
	add $0x02, %si # skip len

	# TODO: history fparse -> file_linec=hist_idx
	#xor %ax, %ax
	#mov %ax, (hist_stack)
	#mov %ax, (hist_data)
	jmp .done

.done:
	ret
