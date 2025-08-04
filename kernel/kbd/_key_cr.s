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

	push $kernel_prompt
	call outs
	add $0x02, %sp

	call init_cursor

	# {init.task}
	push $raw_buf
	call clear_buf
	add $0x02, %sp

	mov $raw_buf, %si
	add $0x02, %si # skip len

	# zero stack
	xor %ax, %ax
	mov %ax, (hist_stack)

	jmp .done

.done:
	ret
