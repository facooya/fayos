# === > DATA

cmd_table:
  .word cmd_clear
  .asciz "clear"
  .word cmd_echo
  .asciz "echo"
  .word cmd_touch
  .asciz "touch"
  .word cmd_rm
  .asciz "rm"
  .word cmd_ls
  .asciz "ls"
  .word cmd_cat
  .asciz "cat"
  .word cmd_help
  .asciz "help"
  .word 0x00
  .asciz ""

# === < DATA
# ===
# !!!!!!!
# time, color, mv, cp
# === > FACOOYA
# Copyright 2025 Facooya.
# === < FACOOYA
