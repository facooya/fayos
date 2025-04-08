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
# cmd_mkdir()

# DEPS
# cmd_mkdir()
#   set_dap_lba
#   read_block
#   write_block
#   dap

.code16
.section .text

.global cmd_mkdir

.extern print_newline
.extern set_dap_lba
.extern read_block
.extern write_block
.extern dap

# cmd_mkdir()
cmd_mkdir:
  # prol

  push $0x00
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  # epil
  ret
