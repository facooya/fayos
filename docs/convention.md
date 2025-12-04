### Commit
#### Types
- build
- chore
- docs
- refactor
- feat
- fix
- test
- debug

#### Usage
- `type(scope): message`
- `type: message`

Examples:
- `chore(kernel): clean up`
- `test(fs/bm): test bitmap clear`
- - It is okey if not real path
- `refactor(lib/conv,fs/ind): rename functions`
- `docs: update README.md`

### Comment
- Comment write lower case please. Using simple words. If need description write in docs file not a logic file.
- Condition: (COND) ? {TASK} : {TASK}
- - (fayos == 1) ? {pass} : {end}
- Keyword: {}
- Start block:
- - small: {
- - medium: {{
- - large: {{{
- End block:
- - small: }
- - medium: }}
- - large: }}}
- Information: <>
- - \<ax = ret\_code\>
- Stack: [s.N:KEY]
- - write next comment for `push` and `pop`. skip for prolog and epilog.
- - [s.0:abc]
- - [s.f2:def] - f: function
- Docs: [d.N:KEY]
- - [d.1:init]

### Align
- X: 0x1, 0x123
- O: 0x01, 0x0123, 0x1234

### Data type
- O: .byte, .word, .long, .quad, .fill, .zero, .asciz, .ascii
- X: .short, .int, .string

### Instruction
- O: add, sub
- O: inc, dec
- - If `a+=1` using inc.

- X: movw (%si), %ax
- O: mov (%si), %ax
- X: movb (%si), %al
- O: mov (%si), %al
- - Avoid attache type at instruction.

### Code
- recommend: .global
- avoid: .globl

### Protact
Callee protect registers:
- es, ds, ss, sp
- bp, si, di, bx

Caller protect registers:
- ax, cx, dx

Interrupt protect registers:
- all

> Authors 2025 Facooya and Fanone Facooya
