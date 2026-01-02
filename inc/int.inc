# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

# common
.equ EOI, 0x20
.equ IO_WAIT, 0x80

# { port
.equ PIC1_PORT_CMD, 0x20
.equ PIC1_PORT_DATA, 0x21

.equ PIC2_PORT_CMD, 0xA0
.equ PIC2_PORT_DATA, 0xA1
# }

# { icw
.equ ICW1_ICW4, (0x01<<0x00)
.equ ICW1_INIT, (0x01<<0x04)

.equ ICW2_PIC1, 0x20
.equ ICW2_PIC2, 0x28

.equ ICW3_PIC1_PIC2, (0x01<<0x02)
.equ ICW3_PIC2_IDX, 0x02

.equ ICW4_8086, (0x01<<0x00)
# }

# imr
.equ IMR_IRQ_ALL, 0xFF
.equ IMR_IRQ1, (0x01<<0x01)
.equ IMR_IRQ2, (0x01<<0x02)
.equ IMR_IRQ8, (0x01<<0x00)
.equ IMR_IRQ14, (0x01<<0x06)

# ivt
.equ IVT_ENT_IRQ1, ((ICW2_PIC1 + 0x01) * 0x04)
.equ IVT_ENT_IRQ8, ((ICW2_PIC1 + 0x08) * 0x04)
.equ IVT_ENT_IRQ14, ((ICW2_PIC1 + 0x0E) * 0x04)
