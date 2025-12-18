# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_run

# kbd_run()
# <mod> scancode, kbd_mflg
kbd_run:
	call kbd_upd_mflg
	# <mod: kbd_mflg, scancode>
	# <ax = {skip:0}>

	# (kbd_upd_mflg() == 0) ? {done}
	test %ax, %ax
	jz .done

	call kbd_conv_kc
	# <req: scancode, kbd_mflg>
	# <al = kc>

	call kbd_proc
	# <req: al = kc>

.done:
	xor %ax, %ax
	mov %ax, (scancode)
	ret
