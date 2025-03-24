# =============== > CODE ===============

.code16

# =============== > Key Buffer ===============
# --------------- Set Key Buffer ---------------
set_key_buf:
  mov $key_buf, %di
  ret
# --------------- Set Key Buffer ---------------

init_key_buf:
  mov $key_buf, %si
  jmp init_key_buf_loop

init_key_buf_loop:
  # Compare
  mov (%si), %al
  test %al, %al
  jz init_key_buf_exit

  # Init
  xor %al, %al
  movb %al, (%si)

  # Loop
  inc %si
  jmp init_key_buf_loop

init_key_buf_exit:
  ret

# using enter_key (kbd.inc)
init_cmd_buf: # Temporary
  mov $cmd_buf, %si
  jmp init_key_buf_loop

init_arg_buf: # Temporary
  mov $arg_buf, %si
  jmp init_key_buf_loop

init_opt_buf: # Temporary
  mov $opt_buf, %si
  jmp init_key_buf_loop

init_tmp_buf: # Temporary
  mov $tmp_buf, %si
  jmp init_key_buf_loop

init_redir_buf: # Temporary
  mov $redir_buf, %si
  jmp init_key_buf_loop

# =============== < Key Buffer ===============

# =============== < CODE ===============
# =============== > DATA ===============

key_buf: .zero 0x40
cmd_buf: .zero 0x20
arg_buf: .zero 0x20
opt_buf: .zero 0x10
tmp_buf: .zero 0x20
redir_buf: .zero 0x20

cli_buf_raw: .zero 0x40
cli_buf_cmd: .zero 0x20
cli_buf_arg: .zero 0x20
cli_buf_opt: .zero 0x10
cli_buf_tmp: .zero 0x20
cli_buf_redir: .zero 0x20

# =============== < DATA ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
