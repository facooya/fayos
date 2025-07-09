# Boot
> [!NOTE]
> IRQ: Interrupt Request  
> DAP: Disk Address Packet  

> `cli`: Clear Interrupt  
> `kd`: Kernel Disk  
> `bmsg`: Boot Message  

## Index
- logic
- - `_start()`
- - `.read_kernel_disk()`
- - `.out_str(&str)`
- data
- - boot messages
- - `.dap`

## Workflow
- clear interrupt
- - Unuse IRQ in Fayos boot mode.
- zero init
- set stack
- read kernel disk
- jump to kernel memory
- - `cs` = 0x0000
- - `ip` = 0x1000

---

## Description
### Initialization
- zero initialization except `cs`
- - cs = 0x07C0, ip = 0x0000
- - ip = (cs * 0x10) + ip = 0x7C00
- - ip = 0x7C00

- jump to kernel
- - `cs = 0x0000`
- - `ip = 0x1000`

The `es` and `ss` register is always `0x00` in Fayos.

### Stack
- sp: 0x7C00 (stack pointer start)
- memory: 0x7000-0x7BFF
- count: 1546

### Magic
- Magic number = 0x55AA
- `.word 0xAA55` (little endian)
- `.byte 0x55, 0xAA` (direct push)

#### Calculation
`.fill 0x01FE-(.-_start), 0x01, 0x00`
- Examples: [.=0x7EF0]
- 0x01FE - (0x7EF0 - 0x7C00)
- = 0x01FE - 0x01F0 = 0x000E
- `.fill 0x0E, 0x01, 0x00`
- `.word 0xAA55` (magic number)

> .fill repeat, size, value

---

## Information
### Stack
- memory: 0x7000-0x7BFF

### Boot
- sector count: 1
- LBA: 0
- memory: 0x7C00-0x7DFF

### Kerne1
- sector count: 48
- LBA: 0x10-0x3F
- memory: 0x1000-0x6FFF

---

> Authors: Facooya and Fanone Facooya
