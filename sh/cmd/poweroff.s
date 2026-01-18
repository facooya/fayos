# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_poweroff

# cmd_poweroff()
cmd_poweroff:
	call apm_off
	ret
