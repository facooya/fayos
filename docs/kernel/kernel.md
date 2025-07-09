# Kernel
> CLI: Command Line Interface  

> `kmsg`: kernel message

## Index
- logic
- - `_start()`
- - `kernel_main()`
- data
- kernel messages
- `kernel_prompt`

## Workflow
- init superblock
- init cursor
- set raw buffer
- kernel main
- - require: si = &raw\_buf
- - CLI main

## Kernel Information
LBA: 0x10-0x3F
memory: 0x1000-0x6FFF

---

> Authors: Facooya and Fanone Facooya
