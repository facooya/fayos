# Superblock
## Superblock Structure
Superblock surmmery immutable value:
- magic number = 0xC0DEFAC0 [4-byte]
- superblock LBA = 0x01 [2-byte]
- first LBA = 0x80 [2-byte]
- first block = 0x01 [2-byte]
- first inum = 0x01 [2-byte]
- inode size = 0x20 [2-byte]

Superblock:
- Immutable: [off=0x00]
- - [off+0] magic number [4-byte]
- - [off+4] superblock LBA [2-byte] // TODO: values
- - [off+6] first LBA [2-byte]
- - [off+8] first block [2-byte]
- - [off+10] first inum [2-byte]
- - [off+12] inode size [2-byte] // TODO: bottom

- Disk Parameters: [off=0x20]
- - [0ff+0] buffer size [2-byte]
- - [off+2] flag [2-byte]
- - [off+4] physical cylinders [4-byte]
- - [off+8] physical heads [4-byte]
- - [off+12] physical sectors per track [4-byte]
- - [off+16] sectors [8-byte]
- - [off+24] bytes per sector [2-byte]
- - [off+26] option EDD [4-byte]

- Size: [off=0x40]
- - [off+0] block bitmap size [4-byte]
- - [off+4] inum bitmap size [4-byte]
- - [off+8] inode table size [4-byte]

- Block Count: [off=0x50]
- - [off+0] block bitmap block count [2-byte]
- - [off+2] inum bitmap block count [2-byte]
- - [off+4] inode table block count [2-byte]

- Start LBA [off=0x60]
- - [off+0] block bitmap LBA [4-byte]
- - [off+4] inum bitmap LBA [4-byte]
- - [off+8] inode table LBA [4-byte]
- - [off+12] normal LBA [4-byte]

---

## Superblock Terms
Terms:
- LBA: Logical Block Address
- EDD: Enhanced Disk Drive

---

> Authors: Facooya and Fanone Facooya
