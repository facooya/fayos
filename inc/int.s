# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Constants

# { PIC: Programmable Interrupt Controller
# cmd: icw1, ocw2, ocw3
# data: icw2, icw3, icw4, ocw1
.equ PIC1_PORT_CMD, 0x20 # master
.equ PIC1_PORT_DATA, 0x21

.equ PIC2_PORT_CMD, 0xA0 # slave
.equ PIC2_PORT_DATA, 0xA1
# }

# { ICW: Initialization Command Words
# OCW: Operation Command Words
.equ ICW1_ICW4, (0x01<<0x00)
.equ ICW1_INIT, (0x01<<0x04)

# 0x20-0x2F
.equ ICW2_PIC1, 0x20
.equ ICW2_PIC2, 0x28

.equ ICW3_PIC1_PIC2, (0x01<<0x02) # irq 2
.equ ICW3_PIC2_ID, 0x02 # irq_2 = 2

.equ ICW4_8086, (0x01<<0x00)
# }

# { bit
# IMR: Interrupt Mask Register
.equ IMR_INIT, 0xFF
.equ IMR_BIT_IRQ1, (0x01<<0x01)
.equ IMR_BIT_IRQ2, (0x01<<0x02)
.equ IMR_BIT_IRQ8, (0x01<<0x00)
# }

.equ EOI, 0x20 # end of interrupt
.equ IO_WAIT, 0x80
