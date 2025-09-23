# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video graphic array

.equ VGA_SEG, 0xB800
.equ VGA_OFF, 0x0000

.equ VGA_ROW, 0x0484 # [1-byte]
.equ VGA_COL, 0x044A # [2-byte]

.equ VGA_COLOR_NORM, 0x07 # black:lightgray

# {{{ Cursor
.equ VGA_CURS_IDX_REG, 0x03D4 # [1-byte]
.equ VGA_CURS_DATA_REG, 0x03D5 # [1-byte]

.equ VGA_CURS_IDX_HI, 0x0E
.equ VGA_CURS_IDX_LO, 0x0F
# }}}
