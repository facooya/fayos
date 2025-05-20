# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Arguments

.section .data
.global argc
.global argv

# args
argc: .word 0x00
argv: .zero 0x100

.section .text
.code16
.global trim_raw
.global split_raw
.global build_args
.global clear_buf_old

# ENTRY
# trim_raw()
trim_raw:
	# prol
	push %si
	push %di
	push %bx

	# init
	mov $raw_buf, %si

# LEFT
.trim_raw__left_lp:
	# cond: null ? done
	mov (%si), %al
	test %al, %al
	jz .trim_raw__done

	# cond: space != ? left_end
	cmp $0x20, %al
	jne .trim_raw__left_end

	# loop
	add $0x01, %si
	jmp .trim_raw__left_lp

.trim_raw__left_end:
	# copy
	mov %si, %di
	# si,di = left_valid_idx

	# init {strlen}
	mov $raw_buf, %si

	# call {strlen}
	push %si
	call strlen
	add $0x02, %sp
	mov %ax, %cx # len

	# post {strlen}
	sub $0x01, %cx # get last idx
	add %cx, %si
	mov %si, %bx
	# si,bx = last_idx

# RIGHT
.trim_raw__right_lp:
	# load
	mov (%si), %al

	# cond: space != ? compact
	cmp $0x20, %al
	jne .trim_raw__compact

	# loop
	sub $0x01, %si
	sub $0x01, %bx
	jmp .trim_raw__right_lp

.trim_raw__compact:
	# init
	mov $raw_buf, %si # dst
	# di = left_valid_idx
	# bx = right_valid_idx
	xor %cx, %cx # HACK

# COMPACT
.trim_raw__compact_lp:
	# copy
	mov (%di), %al
	mov %al, (%si)
	
	# cond: di == bx ? zero
	cmp %bx, %di
	je .trim_raw__zero

	# step
	add $0x01, %si
	add $0x01, %di
	add $0x01, %cx
	jmp .trim_raw__compact_lp

# ZERO
.trim_raw__zero:
	# init
	add $0x01, %si

.trim_raw__zero_lp:
	# load
	mov (%si), %al

	# cond: null ? done
	test %al, %al
	jz .trim_raw__done

	# store zero
	xor %al, %al
	mov %al, (%si)

	# step
	add $0x01, %si
	jmp .trim_raw__zero_lp

# DONE
.trim_raw__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret

# ENTRY
# split_raw()
split_raw:
	# prol
	push %si
	push %di

	# clear tmp_buf
	# push $tmp_buf
	# call clear_buf_old
	# add $0x02, %sp
	# TEST
	push $tmp_buf
	call clear_buf
	add $0x02, %sp

	# clear redir_buf
	push $redir_buf
	call clear_buf
	add $0x02, %sp

	# init
	mov $raw_buf, %si
	mov $tmp_buf, %di
	add $0x02, %di
	xor %cx, %cx

# WRITE
.split_raw__write_lp:
	# pre: si = next_char
	# pre: di = write
	# load
	mov (%si), %al

	# TODO raw_buf len
	# cond: null ? copy {escape}
	test %al, %al
	jz .split_raw__copy

	# cond: space ? skip_space
	cmp $0x20, %al
	je .split_raw__skip_space

	# cond: dquote ? single_arg
	cmp $0x22, %al
	je .split_raw__single_arg

	# cond: gt ? chk_redir {escape}
	cmp $0x3E, %al
	je .split_raw__chk_redir

	# store
	mov %al, (%di)

	# step
	add $0x01, %si
	add $0x01, %di
	add $0x01, %cx
	jmp .split_raw__write_lp

# SINGLE_ARG
.split_raw__single_arg:
	# init
	mov %al, (%di)
	add $0x01, %si
	add $0x01, %di

.split_raw__single_arg_lp:
	# load
	mov (%si), %al

	# cond: null ? hdl_dquote_err
	test %al, %al
	jz .split_raw__hdl_dquote_err

	# cond: dquote ? single_arg_chk_esc
	cmp $0x22, %al
	je .split_raw__single_arg_chk_esc

	# store
	mov %al, (%di)

	# step
	add $0x01, %si
	add $0x01, %di
	jmp .split_raw__single_arg_lp

.split_raw__single_arg_chk_esc:
	# pre: al = dquote

	# load
	mov -1(%di), %ah
	
	# cond: backslash != ? single_arg_end
	cmp $0x5C, %ah
	jne .split_raw__single_arg_end

	# store dquote
	mov %al, (%di)
	add $0x01, %di

	# skip
	add $0x01, %si
	jmp .split_raw__single_arg_lp

.split_raw__single_arg_end:
	# pre: al = dquote

	# store dquote
	mov %al, (%di)
	add $0x01, %di

	# store null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di

	# init
	add $0x01, %si
	jmp .split_raw__write_lp

# SKIP_SPACE
.split_raw__skip_space:
	# store null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di

	# (si) = space
	# init
	add $0x01, %si

.split_raw__skip_space_lp:
	# load
	mov (%si), %al

	# cond: space != ? chk_opt
	cmp $0x20, %al
	jne .split_raw__chk_opt

	# step
	add $0x01, %si
	jmp .split_raw__skip_space_lp

.split_raw__chk_opt:
	# (si) != space
	# cond: hyphen ? norm_opt
	cmp $0x2D, %al
	je .split_raw__norm_opt
	
	# next
	jmp .split_raw__write_lp

# NORM_OPT
.split_raw__norm_opt:
	# (si),al = hyphen
	# init
	mov %al, %ah
	add $0x01, %si
	# (si) = opt_char

.split_raw__norm_opt_lp:
	# load opt_char
	mov (%si), %al

	# cond: space ? norm_opt_end
	cmp $0x20, %al
	je .split_raw__norm_opt_end

	# cond: null ? norm_opt_end
	test %al, %al
	jz .split_raw__norm_opt_end

	# store hyphen
	mov %ah, (%di)
	add $0x01, %di

	# store opt_char
	mov %al, (%di)
	add $0x01, %di

	# store null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di

	# step
	add $0x01, %si
	jmp .split_raw__norm_opt_lp

.split_raw__norm_opt_end:
	# (si) = space
	add $0x01, %si

	# next
	jmp .split_raw__write_lp

# REDIR
.split_raw__chk_redir:
	# pre: si,al = gt
	
	# TEST
	mov %cx, (tmp_buf)

	# init
	xor %cx, %cx
	mov $redir_buf, %di
	add $0x02, %di

	# store
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# load
	add $0x01, %si
	mov (%si), %al

	# (raw_buf[off] == space) ? out_redir : err
	cmp $0x20, %al
	je .split_raw__out_redir
	jmp .split_raw__hdl_redir_err

.split_raw__out_redir:
	# pre: si,al = space

	# store
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# load
	add $0x01, %si
	mov (%si), %al

	# (raw_buf[off] == space) ? skip_space_redir : save_redir
	cmp $0x20, %al
	je .split_raw__skip_space_redir
	jmp .split_raw__save_redir

.split_raw__skip_space_redir:
	# load
	mov (%si), %al

	# cond: null ? hdl_redir_err
	test %al, %al
	jz .split_raw__hdl_redir_err

	# (raw_buf[off] != space) ? save_redir : step
	cmp $0x20, %al
	jne .split_raw__save_redir

	# step
	add $0x01, %si
	jmp .split_raw__skip_space_redir

.split_raw__save_redir:
	# load
	mov (%si), %al

	# cond: null ? save_redir_end
	test %al, %al
	jz .split_raw__save_redir_end

	# cond: space ? hdl_redir_err
	cmp $0x20, %al
	je .split_raw__hdl_redir_err

	# store
	mov %al, (%di)

	# step
	add $0x01, %si
	add $0x01, %di
	add $0x01, %cx
	jmp .split_raw__save_redir

.split_raw__save_redir_end:
	# save redir_buf_len
	mov %cx, (redir_buf)

	# clear raw_buf
	push $raw_buf
	call clear_buf_old
	add $0x02, %sp

	# continue
	jmp .split_raw__copy

# COPY
.split_raw__copy:
	# init
	mov %cx, (tmp_buf)
	mov $tmp_buf, %si
	mov (%si), %cx
	add $0x02, %si

	mov $raw_buf, %di

.split_raw__copy_lp:
	# load
	mov (%si), %al

	# cond: null ? chk_copy
	test %al, %al
	jz .split_raw__chk_copy
	# TEST
	# test %cx, %cx
	# jz .split_raw__done

	# cpy
	mov %al, (%di)

	# step
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cx
	jmp .split_raw__copy_lp

.split_raw__chk_copy:
	# store null
	mov %al, (%di)
	add $0x01, %di

	# load
	add $0x01, %si
	mov (%si), %al

	# cond: null ? done
	test %al, %al
	jz .split_raw__done

	# continue
	jmp .split_raw__copy_lp

# DONE
.split_raw__done:
	# epil
	xor %ax, %ax

.split_raw__exit:
	# epil
	pop %di
	pop %si
	ret

# ERR
.split_raw__hdl_dquote_err:
	call outnl

	call hdl_dquote_err

	# err flag
	xor %ax, %ax
	mov $0x01, %ax

	jmp .split_raw__exit

.split_raw__hdl_redir_err:
	call outnl

	call hdl_redir_err

	# clear redir_buf
	push $redir_buf
	call clear_buf
	add $0x02, %sp

	# err flag
	xor %ax, %ax
	mov $0x01, %ax

	jmp .split_raw__exit

# ENTRY
# build_args()
build_args:
	# prol
	push %si
	push %di
	push %ax
	push %bx
	push %cx

	# init {pre-done}
	mov $raw_buf, %si
	xor %cx, %cx # argc

	# load {pre-done}
	mov (%si), %al

	# cond: null ? done {pre-done}
	test %al, %al
	jz .build_args__done

	# clear
	call clear_args

	# init argv
	mov $argv, %di
	xor %bx, %bx # offset
	mov %bx, (%di)
	add $0x02, %di

# ARGV
.build_args__argv_lp:
	mov (%si), %al # load (raw_buf)

	# cond: null ? argc
	test %al, %al
	jz .build_args__argc

	# loop
	add $0x01, %si # raw_buf
	add $0x01, %bx # offset
	jmp .build_args__argv_lp

# ARGC
.build_args__argc:
	add $0x01, %cx # argc

	# chk load (raw)
	add $0x01, %si
	mov (%si), %al

	# cond: null ? done
	test %al, %al
	jz .build_args__done

	# write argv
	add $0x01, %bx # skip null
	mov %bx, (%di) # store (argv)
	add $0x02, %di # argv

	# loop
	jmp .build_args__argv_lp

# DONE
.build_args__done:
	# write argc
	mov $argc, %si
	mov %cx, (%si)

	call set_arg

	# epil
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret

# ENTRY
# clear_buf_old()
clear_buf_old:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	# init
	mov 4(%bp), %si

.clear_buf__zero_lp:
	# load
	mov (%si), %al

	# cond: null ? chk_zero
	test %al, %al
	jz .clear_buf__chk_zero

	# store zero
	xor %al, %al
	mov %al, (%si)

	# loop
	add $0x01, %si
	jmp .clear_buf__zero_lp

.clear_buf__chk_zero:
	# next load
	add $0x01, %si
	mov (%si), %al

	# cond: null ? done
	test %al, %al
	jz .clear_buf__done

	# loop
	jmp .clear_buf__zero_lp

.clear_buf__done:
	# epil
	pop %ax
	pop %si
	pop %bp
	ret
