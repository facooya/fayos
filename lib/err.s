# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error Handler

.section .data
.global redir_type_err_msg
.global redir_req_err_msg
.global redir_extra_err_msg

.opt_err_msg: .asciz "Invalid option."
.arg_err_msg: .asciz "Missing argument."
.quot_err_msg: .asciz "Missing double quote."

.syn_err_msg: .asciz "Syntax error."
.tok_syn_err_msg: .asciz "Token syntax error."
.cmd_syn_err_msg: .asciz "Command syntax error."
.opt_syn_err_msg: .asciz "Option syntax error."

.arg_req_err_msg: .asciz "Argument required."

.redir_err_msg: .asciz "Redirection syntax error."
redir_type_err_msg: .asciz "Invalid redirection type."
redir_req_err_msg: .asciz "Missing redirection target."
redir_extra_err_msg: .asciz "Too many redirection target."

.disk_err_msg: .asciz "Disk error."

.not_found_err_msg: .asciz "Not found."
.not_file_err_msg: .asciz "Not a file."
.not_dir_err_msg: .asciz "Not a dir."

.dup_err_msg: .asciz "Already exists."

.section .text
.code16

.global hdl_opt_err
.global hdl_arg_err
.global hdl_dquote_err # HACK
.global hdl_quot_err

.global hdl_syn_err
.global hdl_tok_syn_err
.global hdl_cmd_syn_err
.global hdl_opt_syn_err

.global hdl_arg_req_err

.global hdl_redir_err
.global hdl_disk_err

.global hdl_not_found_err
.global hdl_not_file_err
.global hdl_not_dir_err
.global hdl_dup_err

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
# hdl_quot_err()
hdl_dquote_err:
hdl_quot_err:
	push $.quot_err_msg
	jmp .hdl_err

# hdl_syn_err()
hdl_syn_err:
	push $.syn_err_msg
	jmp .hdl_err

# hdl_tok_err()
hdl_tok_syn_err:
	push $.tok_syn_err_msg
	jmp .hdl_err

# hdl_cmd_syn_err()
hdl_cmd_syn_err:
	push $.cmd_syn_err_msg
	jmp .hdl_err

# hdl_opt_syn_err()
hdl_opt_syn_err:
	push $.opt_syn_err_msg
	jmp .hdl_err

# hdl_arg_req_err()
hdl_arg_req_err:
	push $.arg_req_err_msg
	jmp .hdl_err

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
# hdl_not_dir_err()
hdl_not_dir_err:
	push $.not_dir_err_msg
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
