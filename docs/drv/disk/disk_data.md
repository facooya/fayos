# Disk Data
## Overview
Data definition for disk.

---

## Table of Contents
- [Data Reference](#data-reference)
- [Reference Links](#reference-links)

---

## Data Reference
| Name | Size | Description |
| --- | --- | --- |
| `dpi` | 0x100 | Immutable disk packet array. Disk packets in DPI array. |

**DP in DPI**
| Name | Size | Description |
| --- | --- | --- |
| Sector Count | 2 | Sector count |
| Memory | 4 | Segment and offset |
| LBA | 2 | Logical Block Address |

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for disk | [docs: disk](/docs/drv/disk/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
