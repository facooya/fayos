# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

# normal
.equ CHR_BS, 0x08
.equ CHR_LF, 0x0A
.equ CHR_CR, 0x0D
.equ CHR_SP, 0x20
.equ CHR_QT, 0x22
.equ CHR_HS, 0x23
.equ CHR_DL, 0x24
.equ CHR_AP, 0x27
.equ CHR_HY, 0x2D
.equ CHR_PRD, 0x2E
.equ CHR_SL, 0x2F
.equ CHR_BSL, 0x5C
.equ CHR_COL, 0x3A
.equ CHR_US, 0x5F
.equ CHR_LT, 0x3C
.equ CHR_EQ, 0x3D
.equ CHR_GT, 0x3E
.equ CHR_ZERO, 0x30
.equ CHR_NINE, 0x39

.equ CHR_UC_A, 0x41
.equ CHR_UC_Z, 0x5A 
.equ CHR_LC_A, 0x61
.equ CHR_LC_N, 0x6E
.equ CHR_LC_Z, 0x7A
.equ CHR_CASE_MASK, 0x20

# attribute
.equ ATTR_MARK, 0x01
.equ ATTR_STD, 0x07
.equ ATTR_DIR, 0x09
.equ ATTR_ERR, 0x0C
.equ ATTR_WARN, 0x0E
.equ ATTR_TOP, 0x70

.macro NEWLINE
	push $CHR_CR
	call vga_outc
	add $0x02, %sp
	push $CHR_LF
	call vga_outc
	add $0x02, %sp
.endm
