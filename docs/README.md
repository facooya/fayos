# Documentation
Every files follow the documentation rules, Examples:
- `boot/boot.s` - `docs/boot/boot.md`
- `kernel/args/args.s` - `docs/kernel/args/args.md`

---

## Directory Structure
- boot/ - Boot
- cmd/ - Commands
- fayfs/ - File system for Fayos
- include/ - Constants only
- kernel/ - Kernel for Fayos
- lib/ - Library
- tools/ - Misc

---

## LBA Map
- Boot loader: 0x00
- Superblock: 0x01
- Kernel: 0x10-0x3F
- Block bitmap: block\_bitmap > 0x40
- Inum bitmap: inum\_bitmap > block\_bitmap
- Inode: inode > inode\_bitmap
- Normal: normal > inode

---

## Memory Map
### Conventional Memory
- BIOS Interrupt Vector Table: 0x00 - 0x03FF
- BIOS Data Area: 0x0400 - 0x04FF
- Free Memory: 0x0500 - 0x9FBF
- Extended BIOS Data Area: 0x9FC0 - 0x9FFF

### Upper Memory Area
- Free Memory 0x010000 - 0x09FFFF
- VGA Text Mode 0x0A0000 - 0x0AFFFF
- VGA Monochrome Text Mode 0x0B0000 - 0x0B7FFF
- VGA Graphics Mode 0x0B8000 - 0x0BFFFF
- Upper Memory Block 0x0C0000 - 0x0EFFFF
- BIOS ROM 0x0F0000 - 0x0FFFFF

#### Upper Memory Calculation
segment:offset  
(segment * 0x10) + offset = memory
Examples:
- segment = 0x1000
- offset = 0xABCD
- - (0x1000 * 0x10) + 0xABCD = 0x010000 + 0xABCD = 0x01ABCD

### Fayos
Conventional Free Memory: [0x0500-0x9FBF]
- padding for superblock: 0x0500-0x05FF
- superblock: 0x0600-0x07FF
- padding for kernel: 0x0800-0x0FFF (align: 0x1000)
- kernel: 0x1000-0x6FFF (max: 48 sectors)
- stack: 0x7000-0x7BFF (start: 0x7C00, max: 1536 stacks, 6 sectors)
- boot loader: 0x7C00-0x7DFF (1 sector)
- unset: 0x7E00-0x7FFF (padding, unuse)
- inner: 0x8000-0x9DFF (max: 15 sectors)
- unset: 0x9E00-0x9FBF (padding, unuse)

Free: 0x010000 - 0x09FFFF (max: 1152 sectors, 144 blocks)
