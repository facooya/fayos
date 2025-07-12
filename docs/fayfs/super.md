# Superblock
> [!NOTE]
> LBA: Logical Block Address  
> EDD: Enhanced Disk Drive

## Workflow
init\_super
- read superblock LBA
- check exist the superblock
- - exist: read superblock and done
- set data
- read superblock
- set dentry

## Superblock Structure
Superblock surmmery immutable value:
- SB\_MAG = 0xC0DEFAC0 [4-byte]
- SB\_LBA = 0x01 [2-byte]
- FST\_LBA = 0x80 [2-byte]
- FST\_BLK = 0x01 [2-byte]
- FST\_INUM = 0x01 [2-byte]
- I\_SIZE = 0x20 [2-byte]

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

## Allocate LBA
### Calculate Size
Immutable values:
```
RATE_INUM = 4 // Allocate block count per inum
SECTOR_SIZE = 512 // 512 Bytes
RATE_BLOCK = 8 // Allocate sector count in a block
BLOCK_SIZE = 4096 // 4 KiB (SECTOR_SIZE * RATE_BLOCK)
INODE_SIZE = 32 // 32 Bytes
BIT_PER_BYTE = 8 // 8-bit = 1-byte

TOTAL_SECTOR = x // Mutable x by hard disk
```

Expressions:
```
hard_disk_size = TOTAL_SECTOR * SECTOR_SIZE

total_block = TOTAL_SECTOR / RATE_BLOCK
block_bitmap_size = total_block / BIT_PER_BYTE

total_inum = total_block / RATE_INUM
inum_bitmap_size = total_inum / BIT_PER_BYTE

total_inode_size = total_inum * INODE_SIZE
```

Examples:
```
/* --- Example: x = 2048 --- */
TOTAL_SECTOR = 2048

/* TOTAL_SECTOR * SECTOR_SIZE */
hard_disk_size = 2048 * 512 // 1048576 [1 MiB]

/* TOTAL_SECTOR / RATE_BLOCK */
total_block = 2048 / 8 // 256
/* total_block / BIT_PER_BYTE */
block_bitmap_size = total_block / 8 // 32 [32-byte]

/* total_block / RATE_INUM */
total_inum = total_block / 4 // 64
/* total_inum / BIT_PER_BYTE */
inum_bitmap_size = total_inum / 8 // 8 [8-byte]
 
/* total_inum * INODE_SIZE */
total_inode_size = total_inum * 32 // 2048 [2 KiB]

/* Allocate LBA
block_bitmap_size = 32 (1 block (1 sector)) LBA: 0x00-0x07
inum_bitmap_size = 8 (1 block (1 sector)) LBA: 0x08-0x0F
total_inode_size = 2048 (1 block (4 sectors)) LBA: 0x10-0x17
Normal LBA Start: 0x18
*/

/* --- Example: x = 2097152 --- */
TOTAL_SECTOR = 2097152

/* TOTAL_SECTOR * SECTOR_SIZE */
hard_disk_size = 2097152 * 512 // 1073741824 [1 GiB]

/* TOTAL_SECTOR / RATE_BLOCK */
total_block = 2097152 / 8 // 262144
/* total_block / BIT_PER_BYTE */
block_bitmap_size = 262144 / 8 // 32768 [32 KiB]

/* total_block / RATE_INUM */
total_inum = total_block / 4 // 65536
/* total_inum / BIT_PER_BYTE */
inum_bitmap_size = total_inum / 8 // 8192 [8 KiB]
 
/* total_inum * INODE_SIZE */
total_inode_size = total_inum * 32 // 2097152 [2 MiB]

/* Allocate LBA
block_bitmap_size = 32 KiB (8 blocks) LBA: 0x00-0x3F
inum_bitmap_size = 8 KiB (2 blocks) LBA: 0x40-0x4F
total_inode_size = 2 MiB (512 blocks) LBA: 0x50-0x104F
Normal LBA Start: 0x104F
*/
```

### Calculate LBA
Immutable values:
```
FST_LBA = 64 // 0x40, end of kernel lba: 0x3F
BLOCK_SIZE = 4096 // [4 KiB]
RATE_BLOCK = 8 // Allocate sector count in a block
```

Expressions:
```
/* block_bitmap_size:inum_bitmap_size:total_inode_size */
/* 4:1:256 = 1:0.25:64 */
TOTAL_SECTOR = x
block_bitmap_size = TOTAL_SECTOR / 64
inum_bitmap_size = block_bitmap_size / 4
total_inode_size = block_bitmap_size * 64

/* y = *_size, z = *_block_count */
z = y / BLOCK_SIZE;
if (y % BLOCK_SIZE != 0) { z++; }

block_bitmap_lba = FST_LBA
inum_bitmap_lba = block_bitmap_block_count * RATE_BLOCK + block_bitmap_lba
inode_lba = inum_bitmap_block_count * RATE_BLOCK + inum_bitmap_lba
normal_lba = inode_lba_block_count * RATE_BLOCK + inode_lba
```

Examples:
```
/* --- Example: x = 2097152 --- */
TOTAL_SECTOR = 2097152

block_bitmap_size = 2097152 / 64 // 32768 [32 KiB]
inum_bitmap_size = block_bitmap_size / 4 // 8192 [8 KiB]
inode_size = block_bitmap_size * 64 // 2097152 [2 MiB]

block_bitmap_block_count = 32768 / 4096 // 8
inum_bitmap_block_count = 8192 / 4096 // 2
inode_block_count = 2097152 / 4096 // 512

/* Start LBA */
block_bitmap_lba = 64 // FST_LBA:0x40
inum_bitmap_lba = 8 * 8 + 64 // 128:0x80
inode_lba = 2 * 8 + 128 // 144:0xA0
normal_lba = 512 * 8 + 144 // 4240:0x1090
```

Algorithm for LBA:
```c
#define BLOCK_SIZE 4096
#define FST_LBA 64
#define RATE_SECTOR_PER_BLOCK 8

int sizeArr[3] = {block_bitmap_size, inum_bitmap_size, inode_size};
int countArr[3] = {0};

for (int i = 0; i < sizeof(sizeArr); i++) {
  countArr[i] = sizeArr[i] / BLOCK_SIZE;
}

/* Algorithm LBA */
int lbaArr[4] = {0};
lbaArr[0] = FST_LBA;

for(int i = 1; i < sizeof(lbaArr); i++) {
  lbaArr[i] = countArr[i-1] * RATE_SECTOR_PER_BLOCK + lbaArr[i-1];
}

```

---

> Authors: Facooya and Fanone Facooya
