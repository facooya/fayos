# Superblock
> [!NOTE]
> LBA - Logical Block Address
> EDD: Enhanced Disk Drive

## Workflow
### init\_super
- read superblock LBA
- check exist the superblock
- - exist: read superblock and done
- set data
- read superblock
- set dentry

## Superblock Structure
### Superblock surmmery immutable value:
- SB\_MAG = 0xC0DEFAC0 [4-byte]
- SB\_LBA = 0x01 [2-byte]
- FST\_LBA = 0x80 [2-byte]
- FST\_BLK = 0x01 [2-byte]
- FST\_INUM = 0x01 [2-byte]
- I\_SIZE = 0x20 [2-byte]

### SuperBlock:
- Immutable: [off=0x00]
- - [off+0] magic number [4-byte]
- - [off+4] superblock LBA [2-byte]
- - [off+6] first LBA [2-byte]
- - [off+8] first block [2-byte]
- - [off+10] first inum [2-byte]
- - [off+12] inode size [2-byte]

- Disk parameters: [off=0x20]
- - [0ff+0] buffer size [2-byte]
- - [off+2] flag [2-byte]
- - [off+4] physical cylinders [4-byte]
- - [off+8] physical heads [4-byte]
- - [off+12] physical sectors per track [4-byte]
- - [off+16] sectors [8-byte]
- - [off+24] bytes per sector [2-byte]
- - [off+26] option EDD [4-byte]

- Mutable: [off=0x40]
- - [off+0] block bitmap LBA [4-byte]
- - [off+4] inum bitmap LBA [4-byte]
- - [off+8] inode LBA [4-byte]

---

> Authors: Facooya and Fanone Facooya
