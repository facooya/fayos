# Advanced Technology Attachement
## Overview
**Implementation**
- PIO (Progammend Input Output)
- Interrupt

**Drive Mode**
- Master
- LBA (Logical Block Address)

---

## Table of Contents
- [Module Map](#module-map)
- [Register Map](#register-map)
- [Data Reference](#data-reference)
- [Function Reference](#function-reference)
- [Notes](#notes)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| Main | `/drv/ata.s` | [docs: ata](/docs/drv/ata.md) |
| Header | `/inc/drv/ata.inc` | [docs: ata header](docs/inc/drv/ata_header.md) |
| Interrupt handler | `/int/isr_ata.s` | [docs: isr ata](docs/int/isr_ata.md) |

---

## Register Map
**Port**
| Name | Port | Byte | Mode |
| :--- | :---: | :---: | :---: |
| Data | 0x01F0 | 2 | IO |
| Error | 0x01F1 | 1 | IN |
| Feature | 0x01F1 | 1 | OUT |
| Sector count | 0x01F2 | 1 | OUT |
| LBA low | 0x01F3 | 1 | OUT |
| LBA mid | 0x01F4 | 1 | OUT |
| LBA high | 0x01F5 | 1 | OUT |
| Drive | 0x01F6 | 1 | OUT |
| Status | 0x01F7 | 1 | IN |
| Command | 0x01F7 | 1 | OUT |
| Alternate status | 0x03F6 | 1 | IN |
| Device control | 0x03F6 | 1 | OUT |

**Drive Register**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 0-3 | LBA highest | 0 | LBA b24-27. Set 0 only, not use. |
| 4 | Drive mode | 0=master, 1=slave | Master only |
| 5 | N/A | 1 | Always 1 |
| 6 | LBA | 0=CHS, 1=LBA | LBA only |
| 7 | N/A | 1 | Always 1 |

**Status Register**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 0 | Error | 0=false, 1=true | N/A |
| 3 | Data request | 0=false, 1=true | Set when sector ready to read, Or after write end if not sector count 0. Working every sectors. Data request if set is already busy bit 0 and drive ready bit 1. |
| 6 | Drive ready | 0=false, 1=true | Check when drive change, And before write to command  |
| 7 | Busy | 0=false, 1=true | Check when with drive ready, If busy bit 0 and drive ready bit 1 is safe. |

**Drive Control Register**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 1 | Nagative interrupt enable | 0=enable, 1:disable | Always 0 except in `ata_get_sect()` |

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

## Function Reference
### `ata_get_sect`
#### Overview
Identify device commend and read device data and return number of total sectors. If sectors over maximum or not divided sector count per block, Limit maximum value or turncated.

#### Parameters
- `N/A`

#### Requires
- `N/A`

#### Modifies
- `N/A`

#### Returns
- `dx:ax = tot_sect_hi:tot_sect_lo`

#### Process Flow
```mermaid
graph TD
```

#### Implementation
1. Disable interrupt using nIEN
    - delay 400ns
1. Set drive using master and LBA
    - delay 400ns
1. Check BSY bit and DRDY bit
    - ready for BSY=0, DRDY=1
1. Command for identify device
    - delay 400ns
    - ready for DRQ=1
1. Read data
    - before loop for count=0
    - if count is same total sectors offset, save total sectors value in `dx:ax`
1. Check maximum
    - if over maximum value, change total sectors value is maximum value
1. Check turncate
    - turncat remain if total sectors not divided sector count per block
1. Enable interrupt using nIEN
    - delay 400ns

#### Reference Notes
| Description | Link |
| --- | --- |
| Why using nIEN | [docs: ata nIEN](#note-nien) |
| Why delay 400ns | [docs: ata delay 400ns](#note-delay-400ns) |

---

### `ata_init`
#### Overview
Interrupt enable. Clear nIEN bit in DCR.

#### Parameters
- `N/A`

#### Requires
- `N/A`

#### Modifies
- `N/A`

#### Returns
- `N/A`

#### Process Flow
```mermaid
graph TD
```

#### Implementation
- Enable interrupt using nIEN bit

#### Reference Notes
| Description | Link |
| --- | --- |
| Why using nIEN | [docs: ata nIEN](#note-nien) |
| Why delay 400ns | [docs: ata delay 400ns](#note-delay-400ns) |

---

### `ata_read_sect`
#### Overview
Data transfer mode PIO and interrupt mode. Trigger `isr_ata` by irq 14.

#### Parameters
1. `ub16 *seg`
1. `ub16 *off`
1. `ub16 LBA`
1. `ub16 sect_cnt`

#### Requires
- interrupt enable
    - `sti` and clear nIEN bit in DCR

#### Modifies
- `ata_buf`

#### Returns
- `dx:ax = seg:off`

#### Process Flow
```mermaid
graph TD
```
1. Save segment and offset in `ata_buf` structure
1. Set drive mode
    - Set drive, master and LBA
1. Wait 400ns
1. Check BSY bit and DRDY bit
    - Ready for BSY=0, DRDY=1
1. Write sector conut and LBA in registers
    - Sector count in `ata_buf` too
    - LBA high value set 0
    - - [1 Byte] lba\_lo, [1 Byte] lba\_mid
1. Disable interrupt
1. Send command for read
    - Command value in `ata_buf` too
1. Wait 400ns
1. Enable interrupt
1. Start ATA interrupt handler
1. Loop till sector count 0

#### Implementation
- Drive mode master and LBA
- PIO mode
- Interrupt

#### Reference Notes
| Description | Link |
| --- | --- |
| Why delay 400ns | [docs: ata delay 400ns](#note-delay-400ns) |

---

### `ata_write_sect`
#### Overview
Data transfer mode PIO and interrupt mode. Trigger `isr_ata` by irq 14.

#### Parameters
1. `ub16 *seg`
1. `ub16 *off`
1. `ub16 lba`
1. `ub16 sect_cnt`

#### Requires
- interrupt enable
    - `sti` and clear nIEN bit in DCR

#### Modifies
- `ata_buf`

#### Returns
- `dx:ax = seg:off`

#### Process Flow
```mermaid
graph TD
```
1. Save segment and offset in `ata_buf` structure
1. Set drive mode
    - Set master and LBA mode.
1. Wait 400ns
1. Check BSY bit and DRDY bit
    - Ready for BSY=0, DRDY=1
1. Write sector conut and LBA in registers
    - Sector count in `ata_buf` too
    - LBA high value set 0
    - - [1 Byte] lba\_lo, [1 Byte] lba\_mid
1. Send command for write
    - Command value in `ata_buf` too
1. Wait 400ns
1. Check BSY bit and DRQ bit.
    - Ready for BSY=0, DRQ=1
1. Disable interrupt - `cli`
    - Very danger work. Data segment modifiy for outsw.
1. Write 1 sector
    - `outsw` using `ds:si` registers
    - Repeat 256 times. 256:times \* 2:word = 512:bytes, 1 sector size = normal 512-byte
1. Wait 400ns
    - Must using alternate status register. If read status register do clear interrupt signal. Alternate status register read status code is same and not clear interrupt signal.
1. Offset update in `ata_buf`
1. Enable interrupt - `sti`
1. Start ATA interrupt handler (`isr_ata`)
1. Loop till sector count 0


#### Implementation
- Drive mode master and LBA
- PIO mode
- Interrupt

#### Reference Notes
| Description | Link |
| --- | --- |
| Why delay 400ns | [docs: ata delay 400ns](#note-delay-400ns) |

---

## Notes
### Note Delay 400ns
The "ns" is nano second.
- Q. Why 400ns?
- A. Hardware ready time least wait 400ns. CPU is so fast.
- Q. Where include?
- A. Write at Command Register, Contorl Register and Data register read and write after.
- Q. How make 400ns?
- A. `in $STAT_REG, %al` is `in $0x01F7, %al` or `in $0x03F6, %al`. 0x01F7 port is status register and 0x03F6 is alternate status register. So 1 time `in $STAT_REG, %al` is 100ns. Include 4 times it is 400ns.

### Note nIEN
nIEN: negative interrupt enable
- Q. Why using `nIEN`?
- A. Turn off interrupt using `cli` is clear interrupt. But steel have inetrrupt signal write ISR. So turn on interrupt using `sti` go to interrupt handler. But using `nIEN` is turn off interrupt signal. ISR don't know signal even if status is `sti`. So no interrupt request signal.
- Q. When use?
- A. Must not go to interrupt handler. Example identifiy device must not go to interrupt handler. Because method is polling. And different logic.

---

## Terms
| Name | Description |
| --- | --- |
| ATA | Advanced Technology Attachment |
| PIO | Programmed Input Output |
| LBA | Logical Block Address |
| IRQ | Interrupt Request |
| ISR | Interrupt Service Routine |
| DCR | Device Control Register |
| NIEN, nIEN | Negative Interrupt Enable |
| DRV | Drive |
| DRQ | Data Request |
| DEV | Device |

| Description | Link |
| --- | --- |
| Common terms | [common terms](/docs/README.md) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Header for ATA | [docs: inc ata](/docs/inc/drv/ata.md) |
| Interrupt handler for ATA | [docs: isr ata](/docs/int/isr_ata.md) |
| Main document for driver | [docs: driver](/docs/drv/README.md) |
| External link: Standard document for ATA PIO mode | [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
