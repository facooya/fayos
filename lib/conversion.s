# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global ub8_dec_to_chr
.global ub8_hex_to_dec

# ub8_dec_to_chr(ub8 dec)
# <ret: [ah:al] = [chr_hi:chr_lo]>
ub8_dec_to_chr:
	push %bp
	mov %sp, %bp

	mov 0x04(%bp), %ax
	mov %al, %ah

	# { hi ub4
	and $0xF0, %ah
	shr $0x04, %ah
	add $0x30, %ah # <ret:chr_hi>
	# }

	# { lo ub4
	and $0x0F, %al
	add $0x30, %al # <ret:chr_lo>
	# }

	pop %bp
	ret

# ub8_hex_to_dec(ub8 hex)
# <ret: [ah:al] = [dec_hi:dec_lo]>
ub8_hex_to_dec:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %ax # (ub8 hex)
	xor %ah, %ah
	xor %bx, %bx # buf
	xor %cx, %cx # shl

1:
	# (quotient == 0) ? {end}
	test %ax, %ax
	jz 90f

	# ax /= 10
	push %cx # [s.c0:shl]
	mov $0x0A, %cx
	xor %dx, %dx
	div %cx
	and $0x0F, %dl # remainder
	pop %cx # [s.c0:shl]
	shl %cl, %dx
	or %dx, %bx # store

	add $0x04, %cl # shl
	jmp 1b

90:
	mov %bx, %ax # <ret>

	pop %bx
	pop %bp
	ret
