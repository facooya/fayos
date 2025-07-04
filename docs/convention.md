### Commit
#### Types
- build
- chore
- docs
- refactor
- feat
- fix

#### Usage
- `type(scope): message`
- `type: message`

Examples:
- `chore(kernel): clean up`
- `docs: update README.md`

### Comment
- Condition: ()
- Keyword: {}
- Start block: {{{
- End block: }}}
- Information: <>
- Docs: []

### Align
- X: 0x1, 0x123
- O: 0x01, 0x0123, 0x1234

### Data type
- O: .byte, .word, .long, .quad, .fill, .zero, .asciz, .ascii
- X: .short, .int, .string

### Instruction
- X: lods, stos, rep, loop
- O: add, sub
- X: inc, dec

- X: movw (%si), %ax
- O: mov (%si), %ax
- X: movb (%si), %al
- O: mov (%si), %al

### Code
- recommend: .global  
- avoid: .globl  
