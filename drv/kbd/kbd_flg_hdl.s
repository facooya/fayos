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
	cmp $PS2_SC_LSHF, %ax
	je .lshf__set

	# (sc == rshf) ? {rshf.set}
	cmp $PS2_SC_RSHF, %ax
	je .rshf__set

	# (sc == lctl) ? {lctl.set}
	cmp $PS2_SC_LCTL, %ax
	je .lctl__set

	# (sc == rctl) ? {rctl.set}
	cmp $PS2_SC_RCTL, %ax
	je .rctl__set

	# (sc == lalt) ? {lalt.set}
	cmp $PS2_SC_LALT, %ax
	je .lctl__set

	# (sc == ralt) ? {ralt.set}
	cmp $PS2_SC_RALT, %ax
	je .rctl__set

	# (sc == caps) ? {cap.set}
	cmp $PS2_SC_CAP, %ax
	je .cap__set

	jmp .done # cont

.clr:
	# (sc_brk == lshf) ? {lshf.clr} : {done}
	cmp $PS2_SC_LSHF, %dx
	je .lshf__clr

	# (sc_brk == rshf) ? {rshf.clr} : {done}
	cmp $PS2_SC_RSHF, %dx
	je .rshf__clr

	# (sc == lctl) ? {lctl.set}
	cmp $PS2_SC_LCTL, %dx
	je .lctl__set

	# (sc == rctl) ? {rctl.set}
	cmp $PS2_SC_RCTL, %dx
	je .rctl__set

	# (sc == lalt) ? {lalt.set}
	cmp $PS2_SC_LALT, %dx
	je .lctl__set

	# (sc == ralt) ? {ralt.set}
	cmp $PS2_SC_RALT, %dx
	je .rctl__set

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

# {CTL}
.lctl__set:
	or $KBD_FLG_LCTL, %cx
	jmp .done__flg

.lctl__clr:
	and $~KBD_FLG_LCTL, %cx
	jmp .done__flg

.rctl__set:
	or $KBD_FLG_RCTL, %cx
	jmp .done__flg

.rctl__clr:
	and $~KBD_FLG_RCTL, %cx
	jmp .done__flg

# {ALT}
.lalt__set:
	or $KBD_FLG_LALT, %cx
	jmp .done__flg

.lalt__clr:
	and $~KBD_FLG_LALT, %cx
	jmp .done__flg

.ralt__set:
	or $KBD_FLG_RALT, %cx
	jmp .done__flg

.ralt__clr:
	and $~KBD_FLG_RALT, %cx
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
