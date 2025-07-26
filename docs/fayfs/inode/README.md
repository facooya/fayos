# Index Node
## Inode Structure
Inode size = 0x20 [32-byte]
- [off+0] file size [2-byte]
- [off+2] information [2-byte]
- - [off+2] file type [1-byte]
- - [off+3] block length [1-byte]
- [off+4] block array [28-byte]
- - [off+4] block number 0 [4-byte]
- - [off+8] block number 1 [4-byte]
- - [off+12] block number 2 [4-byte]
- - [off+16] block number 3 [4-byte]
- - [off+20] block number 4 [4-byte]
- - [off+24] block number 5 [4-byte]
- - [off+28] block array pointer [4-byte]

block array pointer [4KiB] = capacity block count (1024)

---

## Calculate Inode Table Logic
```asm
# (mem) bx = 0x8000
xor %dx, %dx
pop %ax # inum, before push
mov $I_SIZE, %cx
mul %cx # ax *= cx
add %ax, %bx # set mem
```

Examples:
```asm
xor %dx, %dx
pop %ax # inum = 0x10 (Example value)
mov $I_SIZE, %cx # I_SIZE = 0x20
```
- ax = 0x10 (Example)
- bx = 0x8000 (Example)
- cx = 0x20
- dx = 0x00

```asm
mul %cx # dx:ax *= cx
add %ax, %bx # bx += ax
```
- ax * cx = dx:ax
- - 0x10 * 0x20 = 0x0000:0x0200
- bx += ax
- - 0x8000 + 0x0200 = 0x8200

---

> Authors: Facooya and Fanone Facooya
