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
	push $cl_lbuf
	call bufzero
	add $0x02, %sp

	mov $cl_lbuf, %si
	add $0x02, %si # skip len
	jmp .done

.done:
	ret
