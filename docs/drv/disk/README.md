# Readme for Disk
## Overview
Disk driver. Logic base the ATA (Advanced Technology Attachement) .

---

## Table of Contents
- [Module Map](#module-map)
- [Terms](#terms)
- [Notes](#notes)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| Header for disk | `/inc/drv/disk.s` | [docs: disk header](/docs/inc/drv/disk.md) |
| Data definition | `/drv/disk/disk_data.s` | [docs: disk data](/docs/drv/disk/disk_data.md) |
| Disk set DPI | `/drv/disk/disk_set_dpi.s` | [docs: disk set dpi](/docs/drv/disk/disk_set_dpi.md) |
| Disk load DPI | `/drv/disk/disk_load_dpi.s` | [docs: disk load dpi](/docs/drv/disk/disk_load_dpi.md) |
| Disk read DPI | `/drv/disk/disk_read_dpi.s` | [docs: disk read dpi](/docs/drv/disk/disk_read_dpi.md) |
| Disk write DPI | `/drv/disk/disk_write_dpi.s` | [docs: disk write dpi](/docs/drv/disk/disk_write_dpi.md) |
| Disk read FSP | `/drv/disk/disk_read_fsp.s` | [docs: disk read fsp](/docs/drv/disk/disk_read_fsp.md) |
| Disk write FSP | `/drv/disk/disk_write_fsp.s` | [docs: disk write fsp](/docs/drv/disk/disk_write_fsp.md) |

---

## Terms
| Name | Description |
| --- | --- |
| DP | Disk Packet |
| DPI | Disk Packet Immutable |
| FSP | File System Packet |

---

## Notes

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for ATA | [docs: ata](/docs/drv/ata/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
