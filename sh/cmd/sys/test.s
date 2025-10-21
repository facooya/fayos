# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.include "drv/disk.s"
.include "fs/ind.s"
.include "fs/dentry.s"
.include "fs/sb.s"
.section .data
.str: .asciz "Hello world Hello World 2 Hello world 3 Hello world 4 Hello world 5 Hello world 6 Hello world 7\r\n"
.fname: .asciz "hello"

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:

	push $.fname
	#call fs_add
	add $0x02, %sp

	ret

