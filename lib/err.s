# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error Handler

.section .data

.opt_err_msg: .asciz "Invalid option."
.arg_err_msg: .asciz "Missing argument."
.dquote_err_msg: .asciz "Missing double quote."
.redir_err_msg: .asciz "Redirection syntax error."
.disk_err_msg: .asciz "Disk error."

.not_found_err_msg: .asciz "Not found."
.not_file_err_msg: .asciz "Not a file."

.dup_err_msg: .asciz "Already exists."

.section .text
.code16

.global hdl_opt_err
.global hdl_arg_err
.global hdl_dquote_err
.global hdl_redir_err
.global hdl_disk_err

.global hdl_not_found_err
.global hdl_not_file_err

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

# ENTRY
# hdl_disk_err()
hdl_disk_err:
	push $.disk_err_msg
	call puts
	add $0x02, %sp

	call outnl
	ret

# ENTRY
# hdl_not_found_err()
hdl_not_found_err:
	push $.not_found_err_msg
	jmp .hdl_err

# ENTRY
# hdl_not_file_err()
hdl_not_file_err:
	push $.not_file_err_msg
	jmp .hdl_err

# ENTRY
# hdl_dup_err()
hdl_dup_err:
	push $.dup_err_msg
	jmp .hdl_err

# COMMON
.hdl_err:
	call puts
	add $0x02, %sp
	ret
