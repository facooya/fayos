# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

# conf
.equ VGA_ATTR_COLOR, 0x07
.equ VGA_SCROLL_CNT, 0x19

# common
.equ VGA_MEM, 0xB8000000

# port
.equ VGA_PORT_CURS_CMD, 0x03D4
.equ VGA_PORT_CURS_DATA, 0x03D5

# address
.equ VGA_ADDR_ROW, 0x0484
.equ VGA_ADDR_COL, 0x044A

# command
.equ VGA_CMD_CURS_START, 0x0A
.equ VGA_CMD_CURS_END, 0x0B
.equ VGA_CMD_CURS_POS_HI, 0x0E
.equ VGA_CMD_CURS_POS_LO, 0x0F

# curs
.equ VGA_CURS_DISABLE, (0x01<<0x05)
.equ VGA_CURS_START_LINE, 0x0A
.equ VGA_CURS_END_LINE, 0x0B
.equ VGA_CURS_BLOCK_START_LINE, 0x00
