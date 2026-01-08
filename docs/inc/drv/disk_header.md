# Disk Header
## Overview
Header for disk. Immutable memory address. Disk packet index.

---

## Table of Contents
- [Constants](#constants)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Constants
**Common**
| Name | Description |
| --- | --- |
| `DISK_SB_SECT_CNT` | Sector count for superblock |
| `DISK_SB_LBA` | LBA for superblock |
| `DISK_BLK_SECT_CNT` | Sector count for block |

**Memory**
| Name | Description |
| --- | --- |
| `DISK_SB_MEM` | Memory for superblock |
| `DISK_BBM_MEM` | Memory for block bitmap |
| `DISK_IBM_MEM` | Memory for inum bitmap |
| `DISK_IT_MEM` | Memory for inode table |
| `DISK_CUR_MEM` | Memory for current directory or file |
| `DISK_PAR_MEM` | Memory for parent directory of current directory or file |
| `DISK_TMP_MEM` | Memory for temporary directory or file |
| `DISK_ROOT_MEM` | Memory for root directory |
| `DISK_DIR_MEM` | Memory for directory of path system |
| `DISK_BASE_MEM` | Memory for directory or file of path system |
| `DISK_HIST_MEM` | Memory for history file |

**Disk Packet**
| Name | Description |
| --- | --- |
| `DP_SIZE` | Disk packet total size |
| `DPI_OFF_SB` | DPI offset for superblock |
| `DPI_OFF_BBM` | DPI offset for block bitmap |
| `DPI_OFF_IBM` | DPI offset for inum bitmap |
| `DPI_OFF_IT` | DPI offset inode table |
| `DP_OFF_CUR` | DP offset for current directory or file |
| `DP_OFF_PAR` | DP offset for parent directory of current directory or file |
| `DP_OFF_TMP` | DP offset for temporary directory or file |
| `DP_OFF_ROOT` | DP offset for root directory |
| `DP_OFF_PATH` | DP offset for path system |
| `DP_OFF_SECT_CNT` | DP offset for sector count, Size 2-byte |
| `DP_OFF_MEM` | DP offset for memory, Size 4-byte |
| `DP_OFF_LBA` | DP offset for LBA, Size 2-byte |

---

## Terms
| Name | Description |
| --- | --- |
| DP | Disk Packet |
| DPI | Disk Packet Immutable |
| SB | Superblock |
| BBM | Block Bitmap |
| IBM | Inum Bitmap |
| IT | Inode Table |
| LBA | Logical Block Address |
| PAR | Parent |
| CUR | Current |

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for disk | [docs: disk](/docs/drv/disk.md) |
| Directory document for include | [docs: dir include](/docs/inc/README.md) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
