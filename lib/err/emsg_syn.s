# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error message related to syntax

.section .data
.global emsg_cmd_syn
.global emsg_opt_syn

.global emsg_arg_req

emsg_cmd_syn: .asciz "Command syntax error."
emsg_opt_syn: .asciz "Option syntax error."

emsg_arg_req: .asciz "Argument required."
