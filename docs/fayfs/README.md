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

> **Fayfs** is **FA**coo**Y**a **F**ile **S**ystem

> Authors: Facooya and Fanone Facooya
