# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Interrupt request from keyboard

.section .text
.code16
.global irq_kbd

# irq 0x01 || int $0x21
irq_kbd:
	# <ret> ax:sc, dx:sc_brk
	call ps2_read_sc

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
	# EOI
	mov $0x20, %al
	out %al, $0x20
	iret
