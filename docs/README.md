commit prefix
chore
docs
refactor
feat (Feature)
test
fix
wip (Work In Progress)

Comment Rule

PREVIEW, CODE, DATA, INCLUDE, FACOOYA
PREVIEW: (EXPORT: FUNC, LABEL, DATA), DEPS
FUNC: Function
DEPS: Dependencies

MACRO_NAME() = Macro
label_name = Label, (Jump)
func_name() = Function, (Call)
func_name_exit = Exit (Error)
func_name_done = Done (Safe)

Function naming
verb_noun
verb_prefix
verb_noun_prefix__detail

O: cmp $0x01, %ax
X: cmp $0x00, %ax, O: test %ax, %ax
X: mov $0x00, %ax, O: xor %ax, %ax

done: Function, end: Loop OR Task, exit: Error
_func_name: Private

e.g.,
# func_name(arg_1, arg_2)
push $arg_2
push $arg_1
call func_name # arg_0
add $0x04, %sp # Clear Stack
func_name: # Entry Point
_func_name__set_bp:
  push %bp
  mov %sp, %bp

_func_name__push:
  push %ax
  push %cx

# run OR main
_func_name__run: # Main
  # AX ? Pop
  mov $0x10, %ax
  cmp $0x01, %ax
  jz _func_name__pop

# task OR task_set OR task_loop_set
_func_name__run_task_set: # *_set
  mov $0x03, %cx

# task_loop OR task_[sub_task]_loop
_func_name__run_task_loop: # *_loop
  # CX ? End
  test %cx, %cx
  jz _func_name__run_task_end

  # Loop
  dec %cx
  jmp _func_name__run_task_loop

# task_end OR (task_loop_end | task_end)
_func_name__run_task_end: # *_end
  mov $0x10, %ax

_func_name__pop:
  pop %cx
  pop %ax
  pop %bp

_func_name__done:
  ret

Number Style
X: Decimal
O: Comment (Decimal)

Align [1 Byte]
X: 0x1, 0x123
O: 0x01, 0x0123, 0x1234

Data Type
O: .byte, .word, .long, .quad, .fill, .asciz, .ascii
X: .short, .int, .zero, .string

X: .macro

Instruction
X: lods, stos, rep, loop

O: add, sub
X: inc, dec


UPPERCASE = AND, OR
[REGISTER] e.g., [AX], [BX], Using [SI], Save [BP]
Calculation
[(AL)+1] = [Value+1], [AX+1] = [Addr+1]

b, w, l
mov %ax, %bx
mov $0x10, %bx
movw (%ax), %bx
movw %ax, (%bx)

Unit Rule
[AH][8-bit]
[AL][1-byte]
[AX][2-byte]
[1 KiB], [2 MiB]

