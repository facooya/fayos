# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/ps2.inc"
.include "drv/kbd.inc"
.section .text
.code16
.global kbd_upd_mflg

# kbd_upd_mflg()
# <mod> scancode, kbd_mflg
# <ret> ax = {skip:0}
kbd_upd_mflg:
	mov (kbd_mflg), %cx
	mov (scancode), %ax
	mov %ax, %dx

	# (sc == ext) ? {no_ext}
	test $PS2_SCF_EXT, %dh
	jz .no_ext
	mov $PS2_SC_EXT, %dh
	mov %dh, (scancode+0x01)
	jmp .cont

.no_ext:
	xor %dh, %dh
	mov %dh, (scancode+0x01)

.cont:
	# (sc != brk) ? {set} : {clr}
	test $PS2_SCF_BRK, %ah
	jz .set
	jmp .clr

.set:
	# (sc == lshf) ? {lshf.set}
	cmp $PS2_SC_LSHF, %dx
	je .lshf__set
	# (sc == rshf) ? {rshf.set}
	cmp $PS2_SC_RSHF, %dx
	je .rshf__set

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

	# (sc == caps) ? {cap.set}
	cmp $PS2_SC_CAP, %dx
	je .cap__set

	jmp .done

.clr:
	# (sc_brk == lshf) ? {lshf.clr}
	cmp $PS2_SC_LSHF, %dx
	je .lshf__clr
	# (sc_brk == rshf) ? {rshf.clr}
	cmp $PS2_SC_RSHF, %dx
	je .rshf__clr

	# (sc == lctl) ? {lctl.clr}
	cmp $PS2_SC_LCTL, %dx
	je .lctl__clr
	# (sc == rctl) ? {rctl.clr}
	cmp $PS2_SC_RCTL, %dx
	je .rctl__clr

	# (sc == lalt) ? {lalt.clr}
	cmp $PS2_SC_LALT, %dx
	je .lctl__clr
	# (sc == ralt) ? {ralt.clr}
	cmp $PS2_SC_RALT, %dx
	je .rctl__clr

	xor %ax, %ax
	jmp .done

.lshf__set:
	or $KBD_MFLG_LSHF, %cx
	jmp .done__flg
.lshf__clr:
	and $~KBD_MFLG_LSHF, %cx
	jmp .done__flg

.rshf__set:
	or $KBD_MFLG_RSHF, %cx
	jmp .done__flg
.rshf__clr:
	and $~KBD_MFLG_RSHF, %cx
	jmp .done__flg

.lctl__set:
	or $KBD_MFLG_LCTL, %cx
	jmp .done__flg
.lctl__clr:
	and $~KBD_MFLG_LCTL, %cx
	jmp .done__flg

.rctl__set:
	or $KBD_MFLG_RCTL, %cx
	jmp .done__flg
.rctl__clr:
	and $~KBD_MFLG_RCTL, %cx
	jmp .done__flg

.lalt__set:
	or $KBD_MFLG_LALT, %cx
	jmp .done__flg
.lalt__clr:
	and $~KBD_MFLG_LALT, %cx
	jmp .done__flg

.ralt__set:
	or $KBD_MFLG_RALT, %cx
	jmp .done__flg
.ralt__clr:
	and $~KBD_MFLG_RALT, %cx
	jmp .done__flg

.cap__set:
	test $KBD_MFLG_CAP, %cx
	jnz .cap__clr
	or $KBD_MFLG_CAP, %cx
	jmp .done__flg
.cap__clr:
	and $~KBD_MFLG_CAP, %cx
	jmp .done__flg

.done__flg:
	mov %cx, (kbd_mflg)
	xor %ax, %ax
	jmp .done

.done:
	ret
