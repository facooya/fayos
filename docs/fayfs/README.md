# Fayfs
- `inode` - main inode structure cache data
- `tmp_inode` - sub inode strucutre cache data
- - Example: when using `mkdir`, you need to child inode. Because it will execute add-dentries `.`, `..` like this.

## Directory Structure
- bit/ - Bitmap
- dentry/ - Directory entry
- inode/ - Index node
- super/ - Superblock
- fayfs.s - Cache

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

> **Fayfs** is **FA**coo**Y**a **F**ile **S**ystem

> Authors: Facooya and Fanone Facooya
