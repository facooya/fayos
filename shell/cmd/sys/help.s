# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command help - show commands list

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

	# puts(cmd_str)
	push %si
	call puts
	add $0x02, %sp

	# {{{ len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call strlen
	add $0x04, %sp

	add %ax, %si
	pop %es
	# }}}

	call putnl

	# {lp}
	add $0x01, %si # cmd_map[cmd_addr]
	jmp .lp

.done:
	pop %si
	ret
