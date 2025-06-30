# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put string in write buffer

.section .text
.code16
.global puts
.global putsc

# puts(addr)
puts:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {init}
	mov 0x04(%bp), %si

	mov $write_buf, %di
	mov (%di), %bx # buf.len
	add $0x02, %di # skip len
	add %bx, %di # buf.in

.puts__lp:
	# load
	mov (%si), %al

	# {end.done} (str == null)
	test %al, %al
	jz .puts__done

	# store in write_buffer
	mov %al, (%di)

	# step
	add $0x01, %si
	add $0x01, %di
	add $0x01, %bx
	jmp .puts__lp
	
.puts__done:
	# store len
	mov $write_buf, %di
	mov %bx, (%di)

	pop %bx
	pop %di
	pop %si
	pop %bp
	ret

# FIXME: remove
# putsc(addr) - put string return count
# ret: cx = char count
putsc:
	# prol
	push %bp
	mov %sp, %bp
	push %si

	# init
	mov 0x04(%bp), %si
	xor %cx, %cx

.putsc__lp:
	# load
	mov (%si), %al

	# cond: null ? done
	test %al, %al
	jz .putsc__done

	# body
	call sys_tty_out

	# step
	add $0x01, %si
	add $0x01, %cx
	jmp .putsc__lp
	
.putsc__done:
	# epil
	pop %si
	pop %bp
	ret
