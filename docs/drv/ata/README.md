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

---

## Terms
- ATA: Advanced Technology Attachment
- LBA: Logical Block Address
- IRQ: Interrupt REquest
- ISR: Interrupt Service Routine

---

## Notes
### ATA-delay-400ns
- The "ns" is nano second.
- Q. Why 400ns?
- A. Hardware ready time least wait 400ns. CPU is so fast.
- Q. Where include?
- A. Write at Command Register, Stat Register and Data register read and write after.
- Q. How make 400ns?
- A. `out %al, $IO_WAIT` is `out %al, $0x80`. $0x80 port is nothing. and 1 time `out %al, $0x80` is 100ns. Include 4 times it is 400ns.

---

## Reference Links
- [docs: ata read sect](/docs/drv/ata/ata_read_sect.md)
- [docs: ata write sect](/docs/drv/ata/ata_write_sect.md)
- [docs: ata get sect](/docs/drv/ata/ata_get_sect.md)
- [docs: inc ata](/docs/inc/drv/ata.md)

---

> Authors 2025 Facooya and Fanone Facooya
