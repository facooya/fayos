# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key backspace

# FIXME!!!: Somthing error

.section .text
.code16
.global cli_key_bs

# cli_key_bs()
cli_key_bs:
	call sys_get_cursor

	# {end.done} (cursor.min == cursor.x)
	cmp (cursor), %dl
	je .done

	# {{{
	# update cursor max
	mov (cursor+0x01), %al # cursor.max
	sub $0x01, %al
	mov %al, (cursor+0x01)

	# update len
	mov (raw_buf), %ax # raw.len
	sub $0x01, %ax
	mov %ax, (raw_buf)

	# {step}
	sub $0x01, %si # raw.data
	# }}}

	# {end.call} (raw.data+1 != null)
	mov 0x01(%si), %al
	test %al, %al
	jnz .call_cli_lsh

	# {{{ [d_nsh]
	# left cursor [d_nsh.1]
	sub $0x01, %dl # cursor.x
	call sys_set_cursor

	# overwrite [d_nsh.2]
	call outsp

	# left cursor [d_nsh.3]
	call sys_set_cursor

	# {step} store null [d_nsh.4]
	xor %al, %al
	mov %al, (%si)
	# }}}

.done:
	ret

.call_cli_lsh:
	call cli_lsh
	jmp .done
