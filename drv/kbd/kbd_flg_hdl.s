# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Flag handler

.include "drv/ps2.s"
.include "drv/kbd.s"
.section .data
.global kbd_flg
kbd_flg: .word 0x00

.section .text
.code16
.global kbd_flg_hdl

# kbd_flg_hdl()
# <req> ax = sc
# <req> dx = sc_brk
# <ret> ax = sc (skip=0)
# <ret> kbd_flg
kbd_flg_hdl:
	mov (kbd_flg), %cx

	# (sc_brk == 0) ? {set} : {clr}
	test %dx, %dx
	jz .set
	jmp .clr

.set:
	# (sc == lshf) ? {lshf.set}
	cmp $PS2_SC_LSHF, %al
	je .lshf__set

	# (sc == rshf) ? {rshf.set}
	cmp $PS2_SC_RSHF, %al
	je .rshf__set

	# (sc == caps) ? {cap.set}
	cmp $PS2_SC_CAP, %al
	je .cap__set

	jmp .done # cont

.clr:
	# (sc_brk == lshf) ? {lshf.clr} : {done}
	cmp $PS2_SC_LSHF, %dl
	je .lshf__clr

	# (sc_brk == rshf) ? {rshf.clr} : {done}
	cmp $PS2_SC_RSHF, %dl
	je .rshf__clr

	jmp .done # cont

# {SHF}
.lshf__set:
	or $KBD_FLG_LSHF, %cx
	jmp .done__flg

.lshf__clr:
	and $~KBD_FLG_LSHF, %cx
	jmp .done__flg

.rshf__set:
	or $KBD_FLG_RSHF, %cx
	jmp .done__flg

.rshf__clr:
	and $~KBD_FLG_RSHF, %cx
	jmp .done__flg

# {CAP}
.cap__set:
	test $KBD_FLG_CAP, %cx
	jnz .cap__clr
	or $KBD_FLG_CAP, %cx
	jmp .done__flg

.cap__clr:
	and $~KBD_FLG_CAP, %cx
	jmp .done__flg

# {DONE}
.done__flg:
	mov %cx, (kbd_flg)
	xor %ax, %ax # skip
	jmp .done

.done:
	ret
