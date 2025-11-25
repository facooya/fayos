# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Map

.section .data
.global cmd_map

cmd_map:
	# sys
	.word cmd_test
	.asciz "test"
	.word cmd_clear
	.asciz "clear"
	.word cmd_date
	.asciz "date"
	.word cmd_echo
	.asciz "echo"
	.word cmd_help
	.asciz "help"

	# dir
	.word cmd_pwd
	.asciz "pwd"
	.word cmd_ls
	.asciz "ls"
	.word cmd_cd
	.asciz "cd"
	.word cmd_mkdir
	.asciz "mkdir"
	.word cmd_rmdir
	.asciz "rmdir"

	# file
	.word cmd_cat
	.asciz "cat"
	.word cmd_touch
	.asciz "touch"
	.word cmd_rm
	.asciz "rm"

	# end of cmd_map
	.long 0x00
