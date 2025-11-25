# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Conversion] Deciaml to character

.section .text
.code16
.global ub8_d_to_c

# ub8_d_to_c(ub8 dec)
# <ret> ah:al = chr_hi:chr_lo
ub8_d_to_c:
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
