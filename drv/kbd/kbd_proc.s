# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Keyborad] Process

.section .text
.code16
.global kbd_proc

# kbd_proc()
# <req> scan_code
kbd_proc:
	call kbd_upd_mflg
	# <req: scan_code>
	# <ax = {skip:0}>
	# <mod: kbd_mflg, scan_code>

	# (kbd_upd_mflg() == 0) ? {done}
	test %ax, %ax
	jz .done

	mov (kbd_mflg), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	xor %ax, %ax
	mov %ax, (scan_code)
	jmp .done

	# <req> ax = sc
	# <ret> al = kc
	call kbd_sctokc

	# <req> al = kc
	call kbd

.done:
	xor %ax, %ax
	mov %ax, (scan_code)
	ret
