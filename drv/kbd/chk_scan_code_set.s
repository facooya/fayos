# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Check keyboard scan code set - only using set 2

# command list
# https://wiki.osdev.org/PS/2_Keyboard

.section .text
.code16
.global chk_scan_code_set

# KD 0x60
# KS 0x64
# only using set 2
# chk_scan_code_set()
chk_scan_code_set:
	xor %ax, %ax

	# {{{ disable scan
	mov $0xF5, %al
	out %al, $0x60

	# ok 0xFA
	call ._ibf
	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}}

	# {{{ get current scan code
	# {{ cmd - get/set
	call ._ibf
	mov $0xF0, %al
	out %al, $0x60

	# ok 0xFA
	call ._obf
	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}

	# {{ sub cmd - get
	call ._ibf
	mov $0x00, %al
	out %al, $0x60

	# ok 0xFA
	call ._obf
	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}

	# {{ get scan code
	call ._obf
	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}
	# }}}

	# {{{ enable scan
	mov $0xF4, %al
	out %al, $0x60

	# ok 0xFA
	call ._ibf
	in $0x60, %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}}

.done:
	ret

# {FUNC}
._obf:
	in $0x64, %al
	test $0x01, %al
	jz ._obf
	ret

._ibf:
	in $0x64, %al
	test $0x02, %al
	jnz ._ibf
	ret
