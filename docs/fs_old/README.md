# File system
- `inode` - main inode structure cache data
- `tmp_inode` - sub inode strucutre cache data
- - Example: when using `mkdir`, you need to child inode. Because it will execute add-dentries `.`, `..` like this.

## Directory Structure
- bit/ - Bitmap
- dentry/ - Directory entry
- inode/ - Index node
- super/ - Superblock
- cache.s - Cache

---

> Authors: Facooya and Fanone Facooya
