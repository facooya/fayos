# Readme for ATA
## Overview
The documents for Fayos.
This document for ATA (Advanced Technology Attachement).

**Implementation**
- PIO (Progammend Input Output)
- Interrupt

**Drive Mode**
- Master
- LBA (Logical Block Address)

---

## Table of Contents
- [API Map](#api-map)
- [Register Map](#register-map)
- [Terms](#terms)
- [Notes](#notes)
- [Reference Links](#reference-links)

---

## API Map
### Public
- [docs: ata read sect](/docs/drv/ata/ata_read_sect.md)
- [docs: ata write sect](/docs/drv/ata/ata_write_sect.md)
- [docs: ata get sect](/docs/drv/ata/ata_get_sect.md)

### Interrupt
- [docs: isr ata](docs/int/isr_ata.md)

---

## Register Map
> [!IMPORTANT]
> This register map write for Fayos.
> So table is different to standard.
> Examples if your using LBA 48 bit, So LBA low register 2 byte size is correct not 1.
> But Fayos using LBA 28 bit so using 1 byte size is correct.
> And like "LBA low" is IN and OUT possible. But using OUT only. Because using OUT only in Fayos.
> And "LBA low" register name is differenct to standard, Standard name is "Sector Number Register".

> [!NOTE]
> **You can find standard ATA hardware reference here** [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode)

Align order the port number.
| Name | Port | Byte | Mode |
| :--- | :---: | :---: | :---: |
| Data | 0x01F0 | 2 | IO |
| Error | 0x01F1 | 1 | IN |
| Feature | 0x01F1 | 1 | OUT |
| Sector count | 0x01F2 | 1 | OUT |
| LBA low | 0x01F3 | 1 | OUT |
| LBA mid | 0x01F4 | 1 | OUT |
| LBA high | 0x01F5 | 1 | OUT |
| Drive | 0x01F6 | 1 | IO |
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
| 3 | Drive request | 0=false, 1=true | Set when sector ready to read, Or after write end if not sector count 0. Working every sectors. Drive request if set is already busy bit 0 and drive ready bit 1. |
| 6 | Drive ready | 0=false, 1=true | Check when drive change, And before write to command  |
| 7 | Busy | 0=false, 1=true | Check when with drive ready, If busy bit 0 and drive ready bit 1 is safe. |

**Drive Control Register**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 1 | Nagative interrupt enable | 0=enable, 1:disable | Always 0 except in `ata_get_sect()` |

---

## Terms
- ATA: Advanced Technology Attachment
- LBA: Logical Block Address
- IRQ: Interrupt Request
- ISR: Interrupt Service Routine
- DCR: Device Control Register

- nIEN: Nagative Interrupt Enable

- reg: Register
- drv: Drive
- bsy: Busy
- drq: Drive Rquest
- rdy: Ready
- id: Identifiy
- dev: Device
- sect: Sector
- cnt: Count
- tot: Total
- alt: Alternate
- b: bit

- rev: Reverse
- stat: Status
- seg: Segment
- off: Offset
- lo: Low
- hi: High
- cmd: Command

---

## Notes
### ATA-delay-400ns
- The "ns" is nano second.
- Q. Why 400ns?
- A. Hardware ready time least wait 400ns. CPU is so fast.
- Q. Where include?
- A. Write at Command Register, Contorl Register and Data register read and write after.
- Q. How make 400ns?
- A. `in $STAT_REG, %al` is `in $0x01F7, %al` or `in $0x03F6, %al`. 0x01F7 port is status register and 0x03F6 is alternate status register. So 1 time `in $STAT_REG, %al` is 100ns. Include 4 times it is 400ns.

---

## Reference Links
- [docs: ata read sect](/docs/drv/ata/ata_read_sect.md)
- [docs: ata write sect](/docs/drv/ata/ata_write_sect.md)
- [docs: ata get sect](/docs/drv/ata/ata_get_sect.md)
- [docs: inc ata](/docs/inc/drv/ata.md)

### External
- [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode)

---

> Authors 2025 Facooya and Fanone Facooya
