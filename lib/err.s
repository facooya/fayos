# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error common

.code16
.section .text

.global hdl_opt_err
.global hdl_arg_err

# ENTRY
# hdl_opt_err()
hdl_opt_err:
  push $.opt_err_msg
  call print_str
  add $0x02, %sp

  call print_newline
  ret

# ENTRY
# hdl_arg_err()
hdl_arg_err:
  push $.arg_err_msg
  call print_str
  add $0x02, %sp

  call print_newline
  ret

# DATA
.section .data

.opt_err_msg: .asciz "Invalid option."
.arg_err_msg: .asciz "Missing argument."
