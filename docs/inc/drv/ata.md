# Header for ATA
## Overview
Definition for port, Register value and bit position, Offset for `ata_buf`, Fixed value.
Include some macros for check bit.

> [!IMPORTANT]
> This document write for Fayos.
> So it is different to standard.

> [!NOTE]
> **You can find standard ATA hardware reference here** [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode)

---

## Constants
**PORT**
| Name | Description |
| --- | --- |
| `ATA_PORT_DATA` | Data register, Data in/out 2-byte. |
| `ATA_PORT_ERR` | Error register |
| `ATA_PORT_FEAT` | Feature register |
| `ATA_PORT_SECT_CNT` | Sector count register, Always 8 except superblock. |
| `ATA_PORT_LBA_LO` | LBA low register |
| `ATA_PORT_LBA_MID` | LBA mid register |
| `ATA_PORT_LBA_HI` | LBA high register, unuse set to 0. |
| `ATA_PORT_DRV` | Drive register, Select drive master/slave and LBA/CHS mode. |
| `ATA_PORT_STAT` | Status register, If read clear interrupt signal. Include DRQ, DRDY, BSY bits status. |
| `ATA_PORT_CMD` | Command register |
| `ATA_PORT_ALT_STAT` | Alternate status register, Same status register but not clear interrupt signal. |
| `ATA_PORT_DCR` | Device Control Register, Include nIEN bit. |

**Register**
| Name | Description |
| --- | --- |
| `ATA_DRV_MA_LBA` | Master LBA, Fixed value for using master and LBA mode. |
| `ATA_STAT_DRQ` | Data Request |
| `ATA_STAT_DRDY` | Drive Ready |
| `ATA_STAT_BSY` | Busy |
| `ATA_CMD_ID_DEV` | Identifiy Device |
| `ATA_CMD_READ` | Read |
| `ATA_CMD_WRITE` | Write |
| `ATA_DCR_NIEN` | Negative Interrupt Enable |

**Offset**
| Name | Description |
| --- | --- |
| `ATA_BUF_CMD` | Command |
| `ATA_BUF_CNT` | Count, Remain sector count |
| `ATA_BUF_SEG` | Segment |
| `ATA_BUF_OFF` | Offset |

**Fixed**
| Name | Description |
| --- | --- |
| `ATA_SECT_SIZE_WORD` | Sector size of word, Word is 2-byte. |
| `ATA_OFF_TOT_SECT` | Offset total sectors, Offset read in identifiy device |
| `ATA_MAX_TOT_SECT` | Maximum total sectors, Value is 0x010000, as ATA read LBA is 2-byte. ATA last read LBA is 0xFFF8. And sector count per block is 8. So `0xFFF8+0x08=0x010000`. |

---

## Macro
| Name | Description |
| --- | --- |
| `BSY` | check busy bit in alternate status register. If 0 escape. |
| `DRDY` | check drive ready bit in alternate status register. If 1 escape. |
| `DRQ` | check data request bit in alternate status register. If 1 escape. |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: ata](/docs/drv/ata/README.md) |
| Register Map | [docs: ata register map](/docs/drv/ata/README.md#register-map) |
| External link: standard document | [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode) |

---

> Authors 2025 Facooya and Fanone Facooya
