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
	mov (scan_code), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	xor %ax, %ax
	mov %ax, (scan_code)
	jmp .done

	# <ret> ax:sc, dx:sc_brk
	#call ps2_read_sc

	# <req> ax:sc, dx:sc_brk
	# <ret> ax:sc (skip=0)
	# <ret> mflg
	call kbd_upd_mflg
	# (sc == 0) ? {done(skip)}
	test %ax, %ax
	jz .done

	# <req> ax = sc
	# <ret> al = kc
	call kbd_sctokc

	# <req> al = kc
	call kbd

.done:
	ret
