# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_help

# cmd_help()
cmd_help:
	push %si

	# {init}
	mov $cmd_map, %si

	# {task}
	jmp .lp

.lp:
	# {end.done} (cmd_addr == null)
	mov (%si), %ax
	test %ax, %ax
	jz .done

	add $0x02, %si # cmd_map[cmd_str]

	push %es
	xor %ax, %ax
	mov %ax, %es
	push %si
	push %es
	call puts
	add $0x04, %sp
	pop %es

	# {{{ len
	push %si
	push %ds
	call mem_size
	add $0x04, %sp

	add %ax, %si
	# }}}

	call putnl

	# {lp}
	add $0x01, %si # cmd_map[cmd_addr]
	jmp .lp

.done:
	pop %si
	ret
