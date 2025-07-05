## Directory Structure
- dentry - Directory entry
- inode - Index node
- fayfs.s - cache
- super.s - superblock  

---

## Common note
- off: offset
- dentry: directory entry
- inode: index node

---

## Dentry Structure
dentry size [12-byte - 264-byte]
- [off+0] inode number [4-byte]
- [off+4] record size [2-byte]
- [off+6] information [2-byte]
- - [off+6] file type [1-byte]
- - [off+7] name length [1-byte]
- [off+8] name [1-byte - 255-byte]
- [off+n] dentry size align [0-byte - 3-byte]

### File type
- file:0x80
- dir:0x40

### Dentry size align
- dentrySize % 4 = 0

Examples:
- dentrySize = fix + nameLen + align
- 12 = 8 + 1 + 3
- 12 = 8 + 3 + 1
- 16 = 8 + 6 + 2

Align calculation:
(nameLen + fix + 3) AND 0xFFFC = dentrySize
0xFFFC = (mask) `0b11111111 11111100`
Examples use 1-byte `(mask) 0b11111100`
- nameLen = 1
- - (1 + 8 + 3) = 12
- - 12 = (target) 0b00001100
- - (target) 0b00001100 AND (mask) 0b11111100
- - (target) AND (mask) = 0b00001100 = 0x0C = 12 = dentrySize
- nameLen = 2
- - (2 + 8 + 3) = 13
- - 13 = (target) 0b00001101
- - (target) AND (mask)
- - 0b00001101 AND 0b11111100 = 0b00001100 = 0x0C = 12 = dentrySize
- nameLen = 7
- - (7 + 8 + 3) = 18
- - 18 = (target) 0b00010010
- - (target) AND (mask) = 0b00010010 AND 0b11111100 = 0b00010000 = 16 = dentrySize

---

## Inode Structure
Inode size = 0x20 [32-byte]
- [off+0] file size [2-byte]
- [off+2] information [2-byte]
- - [off+2] file type [1-byte]
- - [off+3] block length [1-byte]
- [off+4] block array [28-byte]
- - [off+4] block number 1 [4-byte]
- - [off+8] block number 2 [4-byte]
- - [off+12] block number 3 [4-byte]
- - [off+16] block number 4 [4-byte]
- - [off+20] block number 5 [4-byte]
- - [off+24] block number 6 [4-byte]
- - [off+28] block array pointer [4-byte]

block array pointer [4KiB] = capacity block count (1024)

---

## Superblock Structure
> [!NOTE]
> LBA: Logical Block Address

Superblock surmmery and default value:
- Immutable data in Fayos:
- - magNum = 0xC0DEFAC0
- - superblockLBA = 0x02
- - inodeLBA = 0x10
- - rootInodeNum = 0x02
- - fstAllocLBA = 0x80
- - fstInodeNum = 0x11
- - rootInodeBlkNum = 0x01
- - inodeSize = 0x20

- Mutable data by Fayos:
- - nextInodeNum = 0x11
- - nextInodeBlkNum = 0x05

SuperBlock detail:
low = lowOff, high = lowOff+2
- [off+0] magic number [4-byte]
- [off+4] superblock LBA [4-byte]
- [off+8] inode LBA [4-byte]
- [off+12] root inode number [4-byte]
- [off+16] first allocate LBA [4-byte]
- [off+20] first inode number [4-byte]
- [off+24] root inode block number [4-byte]
- [off+28] inode size [2-byte]
- [off+30]-[off+64] padding [34-byte]
- [off+64] next inode number [4-byte]
- [off+68] next inode block number [4-byte]

---

> **Fayfs** is **FA**coo**Y**a **F**ile **S**ystem

> Authors: Facooya and Fanone Facooya
