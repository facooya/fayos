# Superblock
## Superblock Structure
Superblock:
- Immutable: [off=0x00]
- - [off+0] magic number [4-byte]

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

Values:
- magic number [4-byte]
- - magic low number = 0xFAC0 [2-byte]
- - magic high number = 0xC0DE [2-byte]
- sector count = 0x01 [2-byte]
- offset memory = 0x0600 [2-byte]
- segment memory = 0x00 [2-byte]
- super LBA [4-byte]
- - super low LBA = 0x01 [2-byte]
- - super high LBA = 0x00 [2-byte]
- first lba = 0x40 [2-byte]

---

## Superblock Terms
Terms:
- LBA: Logical Block Address
- EDD: Enhanced Disk Drive

---

> Authors: Facooya and Fanone Facooya
