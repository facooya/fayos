# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error common

# DATA
.section .data

.opt_err_msg: .asciz "Invalid option."
.arg_err_msg: .asciz "Missing argument."
.dquote_err_msg: .asciz "Missing double quote."
.redir_err_msg: .asciz "Redirection syntax error."

# TEXT
.section .text
.code16

.global hdl_opt_err
.global hdl_arg_err
.global hdl_dquote_err
.global hdl_redir_err

# ENTRY
# hdl_opt_err()
hdl_opt_err:
  push $.opt_err_msg
  call puts
  add $0x02, %sp

  call outnl
  ret

# ENTRY
# hdl_arg_err()
hdl_arg_err:
  push $.arg_err_msg
  call puts
  add $0x02, %sp

  call outnl
  ret

# ENTRY
# hdl_dquote_err()
hdl_dquote_err:
  push $.dquote_err_msg
  call puts
  add $0x02, %sp

  call outnl
  ret

# ENTRY
# hdl_redir_err()
hdl_redir_err:
  push $.redir_err_msg
  call puts
  add $0x02, %sp

  call outnl
  ret
