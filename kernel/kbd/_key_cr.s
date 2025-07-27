# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key carriage return

.section .text
.code16
.global _key_cr

# _key_cr()
_key_cr:
	call exec_cmd

	push $kernel_prompt
	call outs
	add $0x02, %sp

	# reset max cursor
	mov (cursor), %al # cursor.min
	mov %al, (cursor+0x01) # cursor.max

	# {init.task}
	push $raw_buf
	call clear_buf
	add $0x02, %sp

	xor %ax, %ax
	mov $raw_buf, %si
	mov %ax, (%si) # raw.len
	add $0x02, %si # skip len

	jmp .done

.done:
	ret
