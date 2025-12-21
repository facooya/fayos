# Fayos Readme
## Overview
All documents for Fayos.
Code first and test, so documentation may not update.

**Find Documents**
Every assembly files follow the documentation rules.
Examples:
- `/boot/boot.s` - `/docs/boot/boot.md`
- `/drv/ata/ata_init.s` - `/docs/drv/ata/ata_init.md`

Every directories have main document.
Every main document name is `README.md`.
Examples:
- `/boot/` - `/docs/boot/README.md`
- `/drv/` - `/docs/drv/README.md`
- `/drv/kbd/` - `/docs/drv/kbd/README.md`

---

## Table of contents
- [Directory Structure](#directory-structure)
- [File List](#file-list)
- [Memory Map](#memory-map)
- [LBA Map](#lba-map)
- [Terms](#terms)
- [Notes](#notes)

---

## Directory Structure
| Name | Description |
| --- | --- |
| `boot` | Boot |
| `build` | Build. Auto generate if execute `make` command. |
| `docs` | Documents |
| `drv` | Driver |
| `fs` | File system |
| `inc` | Include |
| `int` | Interrupt |
| `kern` | Kernel |
| `lib` | Library |
| `sh` | Shell |
| `tools` | Tools. Misc files, not related Fayos to build. |

---

## File List
| Name | Description |
| --- | --- |
| `Makefile` | Build for Fayos |
| `LICENSE` | License for Fayos |
| `AUTHORS` | Authors for Fayos |
| `NOTICE` | Notice for license |
| `.gitattributes` | Attributes for git |
| `.gitignore` | Ignore files to upload |

---

## Memory Map
| Memory | Defined By | Description |
| :---: | :---: | --- |
| `0x0000-0x007F` | System | CPU exception, BIOS IVT |
| `0x0080-0x00BF` | Fayos | Fayos IVT. Reserved for IRQ service. |
| `0x00C0-0x03FF` | System | BIOS IVT. Fayos read/write. |
| `0x0400-0x04FF` | System | BIOS data area. Fayos read. |
| `0x0500-0x05FF` | Fayos | Padding for superblock |
| `0x0600-0x07FF` | Fayos | Superblock. Size 1 sector. |
| `0x0800-0x0FFF` | Fayos | Padding for kernel. Align to `0x1000`. |
| `0x1000-0x6FFF` | Fayos | Kernel. Total 48 sectors. |
| `0x7000-0x7BFF` | Fayos | Stack. Start to `0x7C00`. Maximum 1536 stacks. Grow down. |
| `0x7C00-0x7DFF` | System | Boot area. Size 1 sector. Fayos entry point. |
| `0x7E00-0x9DFF` | Fayos | Reserved for kernel. Total 2 blocks. |
| `0x9E00-0x9FBF` | Fayos | Unuse |
| `0x9FC0-0x9FFF` | System | Extended BIOS data area |

**4-byte zero padding**
| Memory | Defined By | Description |
| :---: | :---: | --- |
| `0x00010000-0x0009FFFF` | Fayos | Reserved for kernel or program. Total 144 blocks. May use segment `0x1000` area for kernel. |
| `0x000A0000-0x000AFFFF` | System | VGA graphic memory |
| `0x000B0000-0x000B7FFF` | System | VGA monochrome text memory |
| `0x000B8000-0x000BFFFF` | System | VGA color text memory. Fayos read/write. |
| `0x000C0000-0x000EFFFF` | System | Upper memory block |
| `0x000F0000-0x000FFFFF` | System | BIOS ROM |

| Description | Link |
| --- | --- |
| Memory calculation | [note: memory calculation](#note-memory-calculation) |

---

## LBA Map
**Immutable**
| LBA | Sector Count | Description |
| --- | :---: | --- |
| `0x0000` | 1 | Bootloader |
| `0x0001` | 1 | Superblock |
| `0x0002-0x000F` | 14 | Unuse |
| `0x0010-0x003F` | 48 | Kernel |

**Mutable by disk size**
| LBA | Description |
| --- | --- |
| `0x0040-X` | Block bitmap |
| `X+1-Y` | Inum bitmap |
| `Y+1-Z` | Inode table|
| `Z+1-0xFFFF` | Normal |

---

## Terms
| Name | Description |
| --- | --- |
| BIOS | Basic Input Output System |
| IVT | Interrupt Vector Table |
| ROM | Read Only Memory |
| VGA | Video Graphic Address |
| SEG | Segment |
| OFF | Offset |

---

## Notes
### Note Memory calculation
Formula: `(segment * 0x10) + offset = memory`
Examples:
- `seg:off = 0x1000:0xABCD`
- `(0x1000 * 0x10) + 0xABCD = 0x010000 + 0xABCD = 0x01ABCD`
- 4-byte zero padding: `0x0001ABCD`

---

> Authors 2025 Facooya and Fanone Facooya
