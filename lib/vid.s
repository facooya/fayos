# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Misc video library

.code16
.section .text

.global get_mode
.global scroll_up

# ENTRY
# get_mode()
get_mode:
  call sys_get_mode
  ret

# ENTRY
# scroll_up()
scroll_up:
  push %bx
  call sys_scroll_up
  pop %bx
  ret
