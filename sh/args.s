# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.section .text
.code16
.global args_proc

# args_proc()
# <mod> cl_sbuf
# <ret> ax = {true:0, exit:1}
args_proc:
	push %si

	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	# (size == 0) ? {exit}
	test %cx, %cx
	jz 80f

1:
	# (size == 0) ? {exit}
	test %cx, %cx
	jz 80f

	# (chr != sp) ? {end}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne 9f

	inc %si
	dec %cx
	jmp 1b

9:
	call history
	call _args_zero

	# { proc
	call _args_tok
	# <ax = {0:true, 1:exit, 2:skip}>

	# (arg_tok() != true) ? {exit}
	test %ax, %ax
	jnz 80f

	call _args_build

	call _args_parse
	# <ax = {true:0, exit:1, redir:2}>

	# (arg_parse() == exit) ? {exit}
	cmp $0x01, %ax
	je 80f
	# (arg_parse() == redir) ? {redir} : {done}
	cmp $0x02, %ax
	je 91f
	jmp 90f
	# }

80:
	# { zero
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx

	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp
	call _args_zero

	mov $0x01, %ax
	# }
	jmp 99f

91:
	mov $0x02, %ax
	jmp 99f

90:
	xor %ax, %ax
	jmp 99f

99:
	pop %si
	ret

# _args_zero()
# <mod> arg_ccv, tmp_sbuf, redir_hsbuf
_args_zero:
	# { clr tmp_sbuf
	xor %ax, %ax
	mov (tmp_sbuf), %cx
	add $0x02, %cx

	push %cx # (size)
	push %ax # (value)
	push $tmp_sbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp
	# }

	# { clr redir_hsbuf
	xor %ax, %ax
	mov (redir_hsbuf), %cx
	xor %ch, %ch
	add $0x02, %cx

	push %cx # (size)
	push %ax # (value)
	push $redir_hsbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp
	# }

	xor %ax, %ax
	mov $arg_ccv, %si
	mov %ax, (%si) # arg_c
	mov %ax, 0x02(%si) # opt_c
	mov %ax, 0x04(%si) # arg_v[0]
	ret

# _args_tok()
# bx:si = (cl_sbuf) size:chr
# cx:di = (tmp_sbuf) size:chr
# <ret> ax = {0:true, 1:exit, 2:skip}
# <mod> cl_sbuf, tmp_sbuf
_args_tok:
	push %si
	push %di
	push %bx

	# { init
	mov $cl_sbuf, %si
	mov (%si), %bx
	add $0x02, %si

	mov $tmp_sbuf, %di
	add $0x02, %di
	xor %cx, %cx
	# }

	# (cl_sbuf.size == 0) ? {skip} : {gate}
	test %bx, %bx
	jz 91f
	jmp 10f

10: # gate
	mov (%si), %al
	cmp $CHR_SP, %al
	je 11f
	cmp $CHR_QT, %al
	je 14f
	cmp $CHR_HS, %al
	je 13f
	jmp 12f

11: # skip space
	inc %si
	dec %bx

1:
	# (cl_sbuf.size == 0) ? {cpy_buf}
	test %bx, %bx
	jz 20f # cpy buf

	# (cl_sbuf.chr != sp) ? {end}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne 9f

	inc %si
	dec %bx
	jmp 1b

9:
	# (tmp_sbuf.size == 0) ? {gate}
	test %cx, %cx
	jz 10b # gate

	# store null
	xor %al, %al
	mov %al, (%di)
	inc %di
	inc %cx
	jmp 10b # gate

12: # norm chr
1:
	# (cl_sbuf.size == 0) ? {cpy_buf}
	test %bx, %bx
	jz 20f

	# {
	mov (%si), %al

	# (chr == qt) ? {err}
	cmp $CHR_QT, %al
	je 8002f # token syntax

	# (chr == sp) ? {skip_sp}
	cmp $CHR_SP, %al
	je 11b

	# (chr == hash) ? {tok_chr_hs}
	cmp $CHR_HS, %al
	je 1301f

	# store tmp_sbuf
	mov %al, (%di)
	inc %di
	inc %cx
	# }

	inc %si
	dec %bx
	jmp 1b

13: # hash
	dec %cx

1301:
	# (cl_sbuf[i-1].chr != bsl) ? {cpy_buf}
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	jne 20f

	# replace
	mov $CHR_HS, %al
	mov %al, -0x01(%di)

	inc %si
	dec %bx
	jmp 10b # gate

14: # quote
	# skip qt
	inc %si
	dec %bx

1:
	# (cl_sbuf.size == 0) ? {err}
	test %bx, %bx
	jz 8001f

	# (cl_sbuf.chr == qt) ? {chk}
	mov (%si), %al
	cmp $CHR_QT, %al
	je 2f

	# store tmp_sbuf
	mov %al, (%di)
	inc %di
	inc %cx

	inc %si
	dec %bx
	jmp 1b

2:
	# (chr-1 == bsl) ? {chk} ? {end}
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	je 3f
	jmp 9f

3:
	# (chr-2 == bsl) ? {end}
	mov -0x02(%si), %al
	cmp $CHR_BSL, %al
	je 9f

	# replace
	mov $CHR_QT, %al
	mov %al, -0x01(%di)

	inc %si
	dec %bx
	jmp 1b

9:
	inc %si
	dec %bx

	# (size == 0) ? {cpy_buf}
	test %bx, %bx
	jz 20f

	# (chr != sp) ? {err} ? {skip_sp}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne 8002f # token syntax
	jmp 11b

20: # cpy buf
	push %cx # [s.f0:tmp_sbuf.size]
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp
	pop %cx # [s.f0:tmp_sbuf.size]

	# store last null
	xor %ax, %ax
	mov %al, (%di)
	inc %cx

	# {
	mov $tmp_sbuf, %di
	mov %cx, (%di)
	add $0x02, %di

	mov $cl_sbuf, %si
	mov %cx, (%si)
	add $0x02, %si
	# }

# <pre>
# si = *cl_sbuf.chr
# cx:di = (tmp_sbuf) size:chr
1:
	# (size == 0) ? {done}
	test %cx, %cx
	jz 90f

	# cpy
	mov (%di), %al
	mov %al, (%si)

	inc %si # cl.chr
	inc %di # tmp.chr
	dec %cx # tmp.size
	jmp 1b

80:
	mov $0x01, %ax # <ret:code>
	jmp 99f

90:
	xor %ax, %ax # <ret:code>
	jmp 99f

91:
	mov $0x02, %ax # <ret:code>
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	ret

8001:
	NEWLINE
	push $emsg_qt_no
	jmp 8090f

8002:
	NEWLINE
	push $emsg_tok_syn
	jmp 8090f

8090:
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b

# _args_build()
# bx:si = (cl_sbuf) size:chr
# di = *arg_ccv
# cx = arg_c
# dx = off
# <req> cl_sbuf
# <mod> arg_ccv
_args_build:
	push %si
	push %di
	push %bx

	mov $cl_sbuf, %si
	mov (%si), %bx
	add $0x02, %si

	mov $arg_ccv, %di
	add $0x06, %di # skip arg_c+opt_c+arg_v[0]

	xor %cx, %cx # arg_c
	xor %dx, %dx # off
	inc %cx # add arg_v[0]

1:
	# (chr == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz 2f

	inc %si # chr
	dec %bx # size
	inc %dx # off
	jmp 1b

2:
	inc %si # chr
	dec %bx # size
	inc %dx # off

	# (size == 0) ? {end}
	test %bx, %bx
	jz 9f

	# store
	mov %dx, (%di) # off
	add $0x02, %di # step arg_v

	inc %cx # arg_c
	jmp 1b

9:
	# set arg_c
	mov $arg_ccv, %di
	mov %cx, (%di) # arg_c
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	ret

# _args_parse()
# si = (cl_sbuf) chr
# cx = arg_c
# <req> cl_sbuf
# <mod> arg_ccv, redir_hsbuf
# <ret> ax = {true:0, exit:1, redir:2}
_args_parse:
	push %si
	push %di
	push %bx

	mov $cl_sbuf, %si
	add $0x02, %si
	mov $arg_ccv, %di
	mov (%di), %cx # arg_c

	# { chk redir
	dec %si
	# ah = redir.type
	mov 0x01(%si), %dx
	mov $0x11, %ah
	cmp $REDIR_WRITE, %dx
	je 40f
	mov $0x12, %ah
	cmp $REDIR_APPEND, %dx
	jne 1f
	mov 0x03(%si), %al
	test %al, %al
	je 40f

1:
	inc %si
	# }

	# regex_alpha
	push %cx # [s.f0:arg_c]
	push %si # (&chr)
	call regex_alpha
	add $0x02, %sp
	# <ax = {true:0, false:1}>
	pop %cx # [s.f0:arg_c

	# (regex_alpha() != true) ? {err}
	test %ax, %ax
	jnz 8001f # cmd syntax

10: # cmd
1:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz 9f

	inc %si
	jmp 1b

9:
	inc %si # chr
	dec %cx # arg_c

	# (arg_c == 0) ? {done}
	xor %ax, %ax
	test %cx, %cx
	jz 99f

	# (chr == hy) ? {opt} : {arg}
	mov (%si), %al
	cmp $CHR_HY, %al
	je 20f
	jmp 30f

# di = *arg_ccv
# bx = opt_c
# <req>
# (*si == hy)
20: # opt
	xor %bx, %bx # opt_c
	add $0x01, %si # skip hy

# <req> (*si == alpha)
1:
	# (chr == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz 2f

	# regex_alpha
	push %cx # [s.f0:arg_c]
	push %si # (&chr)
	call regex_alpha
	add $0x02, %sp
	# <ax = {true:0, false:1}>
	pop %cx # [s.f0:arg_c]

	# (regex_alpha() != true) ? {err}
	test %ax, %ax
	jnz 8002f # opt syn

	inc %si
	jmp 1b

2:
	# {
	inc %si # skip null
	inc %bx # opt_c

	# (chr != hy) ? {end}
	mov (%si), %al
	cmp $CHR_HY, %al
	jne 9f
	# }

	inc %si # skip hy
	jmp 1b

9:
	# store opt_c
	mov $arg_ccv, %di
	mov %bx, 0x02(%di)

	sub %bx, %cx # arg_c

	# (arg_c == 0) ? {done} : {arg}
	test %cx, %cx
	jz 99f
	jmp 30f

30: # arg
	# { chk redir
	dec %si
	# ah = redir.type
	mov 0x01(%si), %dx
	mov $0x01, %ah
	cmp $REDIR_WRITE, %dx
	je 40f
	mov $0x02, %ah
	cmp $REDIR_APPEND, %dx
	jne 1f
	mov 0x03(%si), %al
	test %al, %al
	je 40f
1:
	# }
	inc %si

# <req> (*si != null)
2:
	# (chr == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz 3f

	inc %si
	jmp 2b

3:
	dec %cx # arg_c
	# (arg_c == 0) ? {end}
	test %cx, %cx
	jz 9f

	# ah = redir.type
	mov 0x01(%si), %dx
	mov $0x01, %ah
	cmp $REDIR_WRITE, %dx
	je 40f
	mov $0x02, %ah
	cmp $REDIR_APPEND, %dx
	jne 1f
	mov 0x03(%si), %al
	test %al, %al
	je 40f
1:

	inc %si
	jmp 2b

9:
	xor %ax, %ax
	jmp 99f

# di = *redir_hsbuf
# dx = off
# <req>
# (*si == null)
# ah = redir.type
40: # redir
	# { clr
	mov $redir_hsbuf, %di
	mov (%di), %dx
	add $0x02, %di
	xor %dh, %dh

	push %ax # [s.f0:type]
	push %cx # [s.f1:arg_c]
	xor %cx, %cx
	push %dx # (size)
	push %cx # (value)
	push %di # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp
	pop %cx # [s.f1:arg_c]
	pop %ax # [s.f0:type]

	xor %dx, %dx
	mov %dx, (redir_hsbuf)
	# }

	xor %dx, %dx
	mov $redir_hsbuf, %di
	mov %ah, %dh # redir.type
	add $0x02, %di # skip type+size

	add $0x02, %si # skip null+redir.type
	dec %cx # arg_c

	# { redir append
	cmp $0x12, %dh
	je 1f
	cmp $0x02, %dh
	je 1f
	jmp 2f
1:
	add $0x01, %si
2:
	# }

	# (chr != 0) ? {err}
	mov (%si), %al
	test %al, %al
	jnz 8003f # redir type

	# (arg_c == 0) { err}
	test %cx, %cx
	jz 8004f # redir req

	# pre
	inc %si # skip null

# <req>
# (*si == chr)
# di = redir.chr
# dl = redir.size
1:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz 9f

	# cpy
	mov %al, (%di)

	inc %si # cl.chr
	inc %di # redir.chr
	inc %dl # redir.size
	jmp 1b

9:
	# store last null
	xor %ax, %ax
	mov %al, (%di)
	inc %di
	inc %dl

	# store hdr
	mov $redir_hsbuf, %di
	mov %dx, (%di) # redir.hdr

	dec %cx # arg_c
	# (arg_c != 0) ? {err}
	test %cx, %cx
	jnz 8005f # redir extra

	# {{{ update arg_c
	mov $arg_ccv, %di
	mov (%di), %ax # arg_c

	# arg_c -= redir.arg
	sub $0x02, %ax
	mov %ax, (%di)
	# }}}

	# (redir.type == cmd) ? {done.redir}
	mov (redir_hsbuf), %ax
	cmp $0x10, %ah
	ja 91f

	xor %ax, %ax
	jmp 99f

80:
	mov $0x01, %ax
	jmp 99f

91: # redir
	sub $0x10, %ah
	mov %ax, (redir_hsbuf)
	mov $0x02, %ax
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	ret

8001:
	NEWLINE
	push $emsg_cmd_syn
	jmp 8090f

8002:
	NEWLINE
	push $emsg_opt_syn
	jmp 8090f

8003:
	NEWLINE
	push $emsg_redir_type
	jmp 8090f

8004:
	NEWLINE
	push $emsg_redir_req
	jmp 8090f

8005:
	NEWLINE
	push $emsg_redir_extra
	jmp 8090f

8090:
	call vga_outs
	add $0x02, %sp
	NEWLINE
	jmp 80b

.section .data
.global arg_ccv
arg_ccv: .zero 0x100
# argc [2-byte]
# optc [2-byte]
# argv [2-byte]-[156-byte]
