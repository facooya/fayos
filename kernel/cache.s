# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# cache

# INDEX
# cwd_lba

# NOTE
# [n_lba]
#   (*_lba): low
#   (*_lba+2): high
#
# [n_free_lba]
#   value: set by kernel

.section .data
.code16

.global cwd_lba
.global free_lba

# cwd_lba [n_lba]
cwd_lba: .long 0x80

# free_lba [n_lba], [n_free_lba]
free_lba: .long 0x88
