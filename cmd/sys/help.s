# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# help

# INDEX
# cmd_help()

# DEPS
# cmd_help()
# outnl
# cmd_map

.section .text
.code16
.global cmd_help

# cmd_help()
cmd_help:
	# prol
	push %si

	# set
	mov $cmd_map, %si

.cmd_help__chk_addr_lp:
	# load cmd_addr
	mov (%si), %ax

	# cond: null ? done
	test %ax, %ax
	jz .cmd_help__done

	call outnl

	add $0x02, %si # cmd_map (cmd_str)

	# print cmd_str
	push %si
	call putsc
	add $0x02, %sp
	add %cx, %si

.cmd_help__out_char_end:
	# loop
	add $0x01, %si # cmd_map (cmd_addr)
	jmp .cmd_help__chk_addr_lp

.cmd_help__done:
	# epil
	pop %si
	ret
