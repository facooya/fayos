# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error message related to syntax

.section .data
.global emsg_cmd_syn
.global emsg_opt_syn
.global emsg_tok_syn

.global emsg_arg_req

.global emsg_qt_no

emsg_cmd_syn: .asciz "Command syntax error."
emsg_opt_syn: .asciz "Option syntax error."
emsg_tok_syn: .asciz "Token syntax error."

emsg_arg_req: .asciz "Argument required."

emsg_qt_no: .asciz "Missing double quote."
