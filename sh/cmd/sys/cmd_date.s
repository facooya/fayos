# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Print date

.include "chr.s"
.include "drv/rtc.s"
.section .data
.week:
	.asciz "Mon",
	.asciz "Tue",
	.asciz "Wed",
	.asciz "Thu",
	.asciz "Fri",
	.asciz "Sat",
	.asciz "Sun"

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
	call ub8_d_to_c
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ax, %cx
	mov %ch, %al
	call putc
	mov %cl, %al
	call putc

	mov RTC_DATE_OFF_YEAR(%si), %al
	push %ax # (ub8 dec)
	call ub8_d_to_c
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
	mov RTC_DATE_OFF_MONTH(%si), %al
	push %ax # (ub8 dec)
	call ub8_d_to_c
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
	mov RTC_DATE_OFF_DAY(%si), %al
	push %ax # (ub8 dec)
	call ub8_d_to_c
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
	mov $.week, %di
	xor %ax, %ax
	mov RTC_DATE_OFF_WEEK(%si), %al
	mov $0x04, %cx
	mul %cx
	add %ax, %di

	xor %ax, %ax
	push %di
	push %ax
	call puts
	add $0x04, %sp
	# }

	mov $CHR_SP, %al
	call putc

	# { hour
	mov RTC_DATE_OFF_HOUR(%si), %al
	push %ax # (ub8 dec)
	call ub8_d_to_c
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
	mov RTC_DATE_OFF_MIN(%si), %al
	push %ax # (ub8 dec)
	call ub8_d_to_c
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
	mov RTC_DATE_OFF_SEC(%si), %al
	push %ax # (ub8 dec)
	call ub8_d_to_c
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
	jmp .done

.done:
	pop %di
	pop %si
	ret
