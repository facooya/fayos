# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/rtc.inc"
.section .text
.code16
.global cmd_date

# cmd_date()
cmd_date:
	push %si
	push %di

	mov $rtc_date, %si

	# { year
	mov $0x20, %al
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc

	mov RTC_DATE_YEAR(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc
	# }

	mov $CHR_HY, %al
	call putc

	# { month
	mov RTC_DATE_MONTH(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc
	# }

	mov $CHR_HY, %al
	call putc

	# { day
	mov RTC_DATE_DAY(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc
	# }

	mov $CHR_SP, %al
	call putc

	# { week
	mov $_week, %di
	xor %ax, %ax
	mov RTC_DATE_WEEK(%si), %al
	dec %al
	mov $0x04, %cx
	mul %cx
	add %ax, %di

	push %di
	push %ds
	call puts
	add $0x04, %sp
	# }

	mov $CHR_SP, %al
	call putc

	# { hour
	mov RTC_DATE_HOUR(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc
	# }

	mov $CHR_COL, %al
	call putc

	# { min
	mov RTC_DATE_MIN(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc
	# }

	mov $CHR_COL, %al
	call putc

	# { sec
	mov RTC_DATE_SEC(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc
	# }

	call putnl
	xor %ax, %ax

	pop %di
	pop %si
	ret

.section .data
_week:
	.asciz "Sun",
	.asciz "Mon",
	.asciz "Tue",
	.asciz "Wed",
	.asciz "Thu",
	.asciz "Fri",
	.asciz "Sat"
