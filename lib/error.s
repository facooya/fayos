# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .rodata
.global emsg_opt_inv
.global emsg_arg_req

.global emsg_redir_type
.global emsg_redir_req
.global emsg_redir_extra

.global emsg_file_no
.global emsg_file_type
.global emsg_file_dup

.global emsg_fs_size
.global emsg_fs_blk_cnt

.global emsg_dir_no
.global emsg_dir_type
.global emsg_dir_dup
.global emsg_dir_root
.global emsg_dir_self

.global emsg_name_dup
.global emsg_name_inv
.global emsg_inv_path
.global emsg_inv_arg

.global emsg_cmd_syn
.global emsg_cmd_not
.global emsg_opt_syn
.global emsg_tok_syn

.global emsg_qt_no

emsg_opt_inv: .asciz "Invalid option."
emsg_arg_req: .asciz "Argument required."

emsg_redir_type: .asciz "Invalid redirection type."
emsg_redir_req: .asciz "Redirection target required."
emsg_redir_extra: .asciz "Too many redirection target"

emsg_file_no: .asciz "File not found."
emsg_file_type: .asciz "Not a file."
emsg_file_dup: .asciz "File already exists."

emsg_fs_size: .asciz "FS: Over size"
emsg_fs_blk_cnt: .asciz "FS: Over block count"

emsg_dir_no: .asciz "Directory not found."
emsg_dir_type: .asciz "Not a directory."
emsg_dir_dup: .asciz "Directory already exists."
emsg_dir_root: .asciz "Directory is root."
emsg_dir_self: .asciz "Can't remove this directory."

emsg_name_dup: .asciz "Name already exists."
emsg_name_inv: .asciz "Wrong name."
emsg_inv_path: .asciz "Invalid path."
emsg_inv_arg: .asciz "Invalid argument."

emsg_cmd_syn: .asciz "Command syntax error."
emsg_cmd_not: .asciz "Command not found."
emsg_opt_syn: .asciz "Option syntax error."
emsg_tok_syn: .asciz "Token syntax error."

emsg_qt_no: .asciz "Missing double quote."
