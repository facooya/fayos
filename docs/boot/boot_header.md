# Boot Header
## Overview
Header for Boot.

---

## Constants
**Common**
| Name | Description |
| --- | --- |
| `CHR_NL` | Character newline |
| `CHR_SP` | Character space |
| `STACK_PTR` | Stack start pointer |
| `KERN_MEM` | Kernel start memroy |
| `KERN_SECT_CNT` | Kernel sector count |
| `KERN_LBA` | Kernel LBA |

**VGA and Display**
| Name | Description |
| --- | --- |
| `VGA_MEM` | VGA Memory |
| `VGA_PORT_CURS_CMD` | Command port for cursor |
| `VGA_PORT_CURS_DATA` | Data port for cursor |
| `VGA_CMD_CURS_POS_HI` | Command to get cursor position high value |
| `VGA_CMD_CURS_POS_LO` | Command to get cursor position low value |
| `VGA_ATTR_COLOR` | Attribute for color. Default value 0x0F: bg=black, fg=white |
| `DISP_ADDR_ROW` | Address for entire row count data |
| `DISP_ADDR_COL` | Address for entire column count data |

**ATA**
| Name | Description |
| --- | --- |
| `ATA_PORT_DATA` | Data port |
| `ATA_PORT_ERR` | Error port |
| `ATA_PORT_FEAT` | Feature port |
| `ATA_PORT_SECT_CNT` | Sector count port |
| `ATA_PORT_LBA_LO` | LBA low port |
| `ATA_PORT_LBA_MID` | LBA mid port |
| `ATA_PORT_LBA_HI` | LBA high port |
| `ATA_PORT_DRV` | Drive port |
| `ATA_PORT_STAT` | Status port |
| `ATA_PORT_CMD` | Command port |
| `ATA_DRV_MA_LBA` | Drive set master and LBA mode |
| `ATA_STAT_DRQ` | Data request bit in status register |
| `ATA_CMD_READ` | Command for read |
| `ATA_SECT_SIZE_WORD` | Sector size count at word |

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for boot | [docs: boot](/docs/boot.md) |
| Document for ATA | [docs: ata](/docs/drv/ata.md) |
| Document for VGA | [docs: vga](/docs/drv/vga.md) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
