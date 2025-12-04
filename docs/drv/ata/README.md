# Readme for ATA
## Overview
You can reference documents easely for ATA.

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
- data: 0x01F0 [2-byte] read or write
- error or feat: 0x01F1 [1-byte] read only

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

---

> Authors 2025 Facooya and Fanone Facooya
