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
| `VGA_PORT_CRTC_CMD` | Command port for CRTC |
| `VGA_PORT_CRTC_DATA` | Data port for CRTC |
| `VGA_CMD_COL` | Return columns count |
| `VGA_CMD_CHR_H` | Character height in bits 0-4 |
| `VGA_CMD_ROW_HI` | Dispaly height high value in bit 1 and bit 6 |
| `VGA_CMD_ROW_LO` | Display height low value in bits 0-7 |
| `VGA_CMD_CURS_POS_HI` | Command to get cursor position high value |
| `VGA_CMD_CURS_POS_LO` | Command to get cursor position low value |
| `VGA_MASK_CHR_H` | Mask for character height |
| `VGA_ROW_HI_8` | Display height high value point to bit 8 |
| `VGA_ROW_HI_9` | Display height high value point to bit 9 |
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

> Maintained by Facooya and Fanone Facooya, 2025-2026
