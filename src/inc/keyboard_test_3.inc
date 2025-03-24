.code16
# =============== > Key Manager ===============

key_manager:
  cmp $0x08, %al # BS
  jz bs_key
  cmp $0x0D, %al # CR
  jz enter_key

  # Else
  mov $0x0E, %ah
  int $0x10

  mov %al, (%di) # DI = key_buf
  inc %di

  jmp key_manager_exit

key_manager_exit:
  ret

# =============== < Key Manager ===============
# =============== > Key Handlers ===============

# --------------- BackSpace ---------------
bs_key:
  mov $0x03, %ah # Get Cursor Pos
  mov $0x00, %bh # Video Page Number
  int $0x10 # DH=Y, DL=X

  mov $0x02, %ah # Set Cursor Pos, DH=Y, DL=X
  cmp (cursor_min_x), %dl
  jz key_manager_exit
  dec %dl
  int $0x10

  mov $0x0E, %ah
  mov $0x20, %al # SP
  int $0x10

  mov $0x02, %ah # Set Cursor Pos, DH=Y, DL=X
  int $0x10

  # key_buf
  movb $0x00, -1(%di)
  dec %di

  jmp key_manager_exit

# --------------- Enter ---------------
enter_key:
  # Command
  call find_cmd # newline() Self

  # Init buffers
  call init_key_buf
  call init_cmd_buf
  call init_arg_buf
  call init_opt_buf
  call init_redir_buf

  push $kernel_prompt
  call print_str
  add $0x02, %sp
  
  mov $key_buf, %di
  jmp key_manager_exit

# =============== < Key Handlers ===============
# =============== > Key Buffer ===============

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

# enter_key
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
# =============== > Utils ===============
# --------------- New Line ---------------
newline:
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10
  ret

# --------------- Set Key Buffer ---------------
set_key_buf:
  mov $key_buf, %di
  ret

# --------------- Set Cursor Minimum X ---------------
set_cursor_min_x:
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10
  mov %dl, (cursor_min_x)
  ret

# =============== < Utils ===============
# =============== > Data ===============

key_buf: .zero 64
cmd_buf: .zero 32
arg_buf: .zero 32
opt_buf: .zero 16
tmp_buf: .zero 32
redir_buf: .zero 0x20

cursor_min_x: .byte 0x00

# =============== < Data ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
