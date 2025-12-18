# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_run

# kbd_run()
# <req> scan_code
kbd_run:
	call kbd_upd_mflg
	# <req: scan_code>
	# <ax = {skip:0}>
	# <mod: kbd_mflg, scan_code>

	# (kbd_upd_mflg() == 0) ? {done}
	test %ax, %ax
	jz .done

	call kbd_sc_to_kc
	# <req: scan_code, kbd_mflg>
	# <al = kc>

	call kbd_proc
	# <req: al = kc>

.done:
	xor %ax, %ax
	mov %ax, (scan_code)
	ret
