# Full stack frame (Facooya standard)
PLACEHOLDER:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %ax
  push %bx
  push %cx
  push %dx

  # epil
  pop %dx
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  pop %bp
  ret
