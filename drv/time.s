# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/rtc.inc"
.section .text
.code16
.global time_upd

# time_upd()
# <mod> rtc_date
time_upd:
	push %si

	xor %ax, %ax
	mov $rtc_date, %si

	# (sec < 60) ? {done} : {zero}
	mov RTC_DATE_SEC(%si), %al
	cmp $0x3C, %al
	jl 90f
	mov %ah, RTC_DATE_SEC(%si)

	# upd min
	mov RTC_DATE_MIN(%si), %al
	inc %al
	mov %al, RTC_DATE_MIN(%si)

	# (min < 60) ? {done} : {zero}
	cmp $0x3C, %al
	jl 90f
	mov %ah, RTC_DATE_MIN(%si)

	# upd hour
	mov RTC_DATE_HOUR(%si), %al
	inc %al
	mov %al, RTC_DATE_HOUR(%si)

	# (hour < 24) ? {done} : {zero}
	cmp $0x18, %al
	jl 90f
	mov %ah, RTC_DATE_HOUR(%si)

	# TODO: call rtc_upd_day

90:
	call time_upd_format
	call vga_upd_top

	pop %si
	ret

# time_upd_format()
time_upd_format:
	push %si
	push %di

	mov $rtc_date, %si
	mov $time_date, %di

	# { year
	mov $0x20, %al
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di

	mov RTC_DATE_YEAR(%si), %al
	push %ax # (ub8 hex)
	call ub8_hex_to_dec
	add $0x02, %sp
	# <ah:al = dec_hi:dec_lo>
	push %ax # (ub8 dec)
	call ub8_dec_to_chr
	add $0x02, %sp
	# <ah:al = chr_hi:chr_lo>
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di
	# }

	mov $CHR_HY, %al
	mov %al, (%di)
	inc %di

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
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di
	# }

	mov $CHR_HY, %al
	mov %al, (%di)
	inc %di

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
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di
	# }

	mov $CHR_SP, %al
	mov %al, (%di)
	inc %di

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
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di
	# }

	mov $CHR_COL, %al
	mov %al, (%di)
	inc %di

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
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di
	# }

	mov $CHR_COL, %al
	mov %al, (%di)
	inc %di

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
	mov %ah, (%di)
	mov %al, 0x01(%di)
	add $0x02, %di
	# }

	mov $CHR_SP, %al
	mov %al, (%di)
	inc %di

	pop %di
	pop %si
	ret

.section .data
.global time_date
time_date: .zero 0x20
