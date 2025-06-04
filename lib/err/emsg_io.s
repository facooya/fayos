# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error message related to I/O

.section .data
.global emsg_redir_type
.global emsg_redir_req
.global emsg_redir_extra

emsg_redir_type: .asciz "Invalid redirection type."
emsg_redir_req: .asciz "Redirection target required."
emsg_redir_extra: .asciz "Too many redirection target"
