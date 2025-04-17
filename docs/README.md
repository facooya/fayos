**Commit**
- chore
- docs
- refactor
- feat
- fix
- wip

type(scope): message  
type: message  
WIP is temporary commit. Don't push. Use "commit -amend".  

**Docs rule**
- INDEX: file function
- DEPS: Dependencies
- NOTE:
  - c: common
  - d: debug
  - n: note

**Function namming**
**V_O__TV_TO_SF**
- V: verb
- O: object
- SF: suffix
  - lp: loop
  - end
  - done
- TV: task verb
- TO: task object

- label_name
- func_name()
- MACRO_NAME()

**Cond rule**
- O: cmp $0x01, %ax
- X: cmp $0x00, %ax, O: test %ax, %ax
- X: mov $0x00, %ax, O: xor %ax, %ax

**Code e.g.,**
```asm
push $arg_2
push $arg_1
call func_name # arg_0
add $0x04, %sp # clear stack

# func_name(arg_1, arg_2)
func_name: # entry point
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %ax
  push %cx

  # init
  mov 4(%bp), %si
  mov 6(%bp), %di

.func_name__chk:
  mov $0x10, %ax

  # cond: ax == 1 ? done
  cmp $0x01, %ax
  jz .func_name__done

.func_name__task:
  mov $0x03, %cx

.func_name__task_lp:
  # cx == 0 ? task_end
  test %cx, %cx
  jz .func_name__task_end

  # step
  sub $0x01, %cx
  jmp .func_name__task_lp

.func_name__task_end:
  mov $0x10, %ax

.func_name__done:
  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  pop %bp
  ret
```

**Align**
X: 0x1, 0x123  
O: 0x01, 0x0123, 0x1234  

**Data Type**
O: .byte, .word, .long, .quad, .fill, .zero, .asciz, .ascii   
X: .short, .int, .string

**Instruction**
X: lods, stos, rep, loop  
O: add, sub  
X: inc, dec  

**Skip b, w**
X: movw (%si), %ax  
O: mov (%si), %ax  
X: movb (%si), %al  
O: mov (%si), %al  
