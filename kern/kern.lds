/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright 2025-2026 Facooya and Fanone Facooya
 */

OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)
ENTRY(kern_run)

SECTIONS {
	. = 0x0000;
	.text : { *(.text) }
	.rodata : { *(.rodata) }
	.data : { *(.data) }
	.bss : { *(.bss) }
}
