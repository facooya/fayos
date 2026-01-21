/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright 2025-2026 Facooya and Fanone Facooya
 */

OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS {
	. = 0x1000;
	.text : { *(.text) }
	.rodata : { *(.rodata) }
	.data : { *(.data) }
	.bss : { *(.bss) }
}
