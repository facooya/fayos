/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright 2025 Facooya and Fanone Facooya
 *
 * Linker description script for kernel
 */

OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS {
	. = 0x1000;
	.text : { *(.text) }
	.data : { *(.data) }
}
