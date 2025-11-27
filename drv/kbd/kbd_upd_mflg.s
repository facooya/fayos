# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Keyboard] Update modifier flag

.include "drv/ps2.s"
.include "drv/kbd.s"
.section .text
.code16
.global kbd_upd_mflg

# kbd_upd_mflg()
# <ret> ax = {skip:0}
# <mod> kbd_mflg, scan_code
kbd_upd_mflg:
	mov (kbd_mflg), %cx
	mov (scan_code), %ax
	mov %ax, %dx

	# (sc == ext) ? {no_ext}
	test $PS2_SC_BIT_EXT, %dh
	jz .no_ext
	mov $PS2_SC_EXT, %dh
	mov %dh, (scan_code+0x01)
	jmp .cont

.no_ext:
	xor %dh, %dh
	mov %dh, (scan_code+0x01)

.cont:
	# (sc != brk) ? {set} : {clr}
	test $PS2_SC_BIT_BRK, %ah
	jz .set
	jmp .clr

.set:
	# Shf
	# (sc == lshf) ? {lshf.set}
	cmp $PS2_SC_LSHF, %dx
	je .lshf__set
	# (sc == rshf) ? {rshf.set}
	cmp $PS2_SC_RSHF, %dx
	je .rshf__set

	# Ctl
	# (sc == lctl) ? {lctl.set}
	cmp $PS2_SC_LCTL, %dx
	je .lctl__set
	# (sc == rctl) ? {rctl.set}
	cmp $PS2_SC_RCTL, %dx
	je .rctl__set

	# Alt
	# (sc == lalt) ? {lalt.set}
	cmp $PS2_SC_LALT, %dx
	je .lctl__set
	# (sc == ralt) ? {ralt.set}
	cmp $PS2_SC_RALT, %dx
	je .rctl__set

	# (sc == caps) ? {cap.set}
	cmp $PS2_SC_CAP, %dx
	je .cap__set

	test $PS2_SC_BRK, %ah
	jz .done
	xor %ax, %ax
	jmp .done

.clr:
	# Shf
	# (sc_brk == lshf) ? {lshf.clr}
	cmp $PS2_SC_LSHF, %dx
	je .lshf__clr
	# (sc_brk == rshf) ? {rshf.clr}
	cmp $PS2_SC_RSHF, %dx
	je .rshf__clr

	# Ctl
	# (sc == lctl) ? {lctl.clr}
	cmp $PS2_SC_LCTL, %dx
	je .lctl__clr
	# (sc == rctl) ? {rctl.clr}
	cmp $PS2_SC_RCTL, %dx
	je .rctl__clr

	# Alt
	# (sc == lalt) ? {lalt.clr}
	cmp $PS2_SC_LALT, %dx
	je .lctl__clr
	# (sc == ralt) ? {ralt.clr}
	cmp $PS2_SC_RALT, %dx
	je .rctl__clr

	xor %ax, %ax
	jmp .done

# {SHF}
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

# {CTL}
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

# {ALT}
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

# {CAP}
.cap__set:
	test $KBD_MFLG_CAP, %cx
	jnz .cap__clr
	or $KBD_MFLG_CAP, %cx
	jmp .done__flg
.cap__clr:
	and $~KBD_MFLG_CAP, %cx
	jmp .done__flg

# {DONE}
.done__flg:
	mov %cx, (kbd_mflg)
	xor %ax, %ax
	jmp .done

.done:
	ret
