# ATA Data
## Overview
Definition data for ATA.

---

## Data Reference
| Name | Size (byte) | Description |
| --- | --- | --- |
| `ata_buf` | 6 | Set by read/write sectors functions. Reference and modified by ISR the name is `isr_ata`. |

**ATA_BUF**
| Name | Size (byte) | Description |
| --- | --- | --- |
| Command | 1 | Store command in read/write sectors functions. Immutable value before next set. |
| Sector Count | 1 | Store sector count by read/write sectors functions. Minus 1 per interrupt by ISR. If 0 is end signal. |
| Segment | 2 | Segment for `insw` or `outsw`. Set in read/write sectors functions before execute `insw` or `outsw`. Immutable value before next set. |
| Offset | 2 | Offset for `insw` or `outsw`. Update by read/write sectors functions or `isr_ata`. And update after every `insw` or `outsw` end. |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent Document | [docs: ata](/docs/drv/ata/README.md) |
| Header for ATA | [docs: inc ata](/docs/inc/drv/ata.md) |
| Interrupt service routine | [docs: isr ata](/docs/int/isr_ata.md) |

---

> Authors 2025 Facooya and Fanone Facooya
