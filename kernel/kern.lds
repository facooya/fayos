OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS {
	. = 0x1000;
	.text : { *(.text) }
	.data : { *(.data) }
}
