# FAYOS - FAcooYa Operating System
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# INDEX
# cwd_lba

# NOTE
# [n_lba]
#   (*_lba): low
#   (*_lba+2): high
#
# [n_next_free_lba]
#   value: set by kernel

.code16
.section .data

.global cwd_lba
.global next_free_lba

# cwd_lba [n_lba]
cwd_lba: .long 0x80

# next_free_lba [n_lba], [n_next_free_lba]
next_free_lba: .long 0x88
