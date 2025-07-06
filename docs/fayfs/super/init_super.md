# Initialization Superblock
> [!NOTE]
> LBA - Logical Block Address

The `init_super()` call only `kernel.s`.
Using LBA [2-3]

## Workflow
- read superblock LBA
- check exist the superblock
- - exist: read superblock and done
- set data
- read superblock
- set dentry

> Authors: Facooya and Fanone Facooya
