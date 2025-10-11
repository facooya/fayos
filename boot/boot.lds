/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright 2025 Facooya and Fanone Facooya
 *
 * Linker description script for boot
 */

OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS {
	. = 0x7C00;
	.text : { *(.text) }
	.rodata : { *(.rodata) }
	.data : { *(.data) }
	.bss : { *(.bss) }
	. = 0x7C00 + 0x1FE;
	.sig : { SHORT(0xAA55) }
}
