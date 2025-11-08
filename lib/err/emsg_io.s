# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Error message related to I/O

.section .data
.global emsg_disk_io

.global emsg_redir_type
.global emsg_redir_req
.global emsg_redir_extra

.global emsg_file_no
.global emsg_file_type
.global emsg_file_dup

.global emsg_dir_no
.global emsg_dir_type
.global emsg_dir_dup
.global emsg_dir_root
.global emsg_dir_self

.global emsg_name_dup
.global emsg_inv_path
.global emsg_inv_arg

emsg_disk_io: .asciz "Disk IO error."

emsg_redir_type: .asciz "Invalid redirection type."
emsg_redir_req: .asciz "Redirection target required."
emsg_redir_extra: .asciz "Too many redirection target"

emsg_file_no: .asciz "File not found."
emsg_file_type: .asciz "Not a file."
emsg_file_dup: .asciz "File already exists."

emsg_dir_no: .asciz "Directory not found."
emsg_dir_type: .asciz "Not a directory."
emsg_dir_dup: .asciz "Directory already exists."
emsg_dir_root: .asciz "Directory is root."
emsg_dir_self: .asciz "Can't remove this directory."

emsg_name_dup: .asciz "Name already exists."
emsg_inv_path: .asciz "Invalid path."
emsg_inv_arg: .asciz "Invalid argument."
