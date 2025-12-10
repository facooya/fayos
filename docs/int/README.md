# Readme for Interrupt
## Overview
Interrupt in Fayos.
Initialization sequence: PIC (Programmable Interrupt Controller), IVT (Interrupt Vector Table), hardware.

---

## Table of Contents
- [Module Map](#module-map)
- [Register Map](#register-map)
- [Terms](#terms)
- [Notes](#notes)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| PIC Initialization | `/int/pic_init.s` | [docs: pic init](/docs/int/pic_init.md) |
| IVT Initialization | `/int/ivt_init.s` | [docs: ivt init](/docs/int/ivt_init.md) |
| ISR PS2 | `/int/isr_ps2.s` | [docs: isr ps2](/docs/int/isr_ps2.md) |
| ISR RTC | `/int/isr_rtc.s` | [docs: isr rtc](/docs/int/isr_rtc.md) |
| ISR ATA | `/int/isr_ata.s` | [docs: isr ata](/docs/int/isr_ata.md) |
| Header for Interrupt | `/inc/int.s` | [docs: int header](/docs/inc/int.md) |

---

## Register Map
**Port**
| Name | Port | Byte | Mode |
| --- | --- | --- | --- |
| PIC1 command | 0x20 | 1 | OUT |
| PIC1 data | 0x21 | 1 | IO |
| PIC2 command | 0xA0 | 1 | OUT |
| PIC2 data | 0xA1 | 1 | IO |

**Command**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 0 | ICW1 ICW4 | 0=false, 1=true | ICW4 will set |
| 4 | ICW1 initialization | 0=false, 1=true | ICW1 initialization  |

**Data**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 0 | ICW4 8086 | 0=8080, 1=8086 | CPU mode |
| 2 | ICW3 PIC1 PIC2 | 0=disable, 1=enable | Interrup request line 2 |

**IMR of PIC1**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 1 | IMR IRQ1 | 0=enable, 1=disable | Interrupt request line 1, For PS2 |
| 2 | IMR IRQ2 | 0=enable, 1=disable | Interrupt request line 2, Enable for PIC2 |

**IMR of PIC2**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 0 | IMR IRQ8 | 0=enable, 1=disable | Interrupt request line 8, For RTC |
| 6 | IMR IRQ14 | 0=enable, 1=disable | Interrupt request line 14, For ATA |

---

## Terms
**Abbreviation**
| Name | Description |
| --- | --- |
| ISR | Interrupt Service Routine |
| PIC | Programmable Interrupt Controller |
| IVT | Interrupt Vector Table |
| ICW | Initialization Command Words |
| OCW | Operation Command Words |
| IMR | Interrup Mask Register |
| EOI | End of Interrupt |

---

## Notes
### Note Data Port
- Q. Why ICW2, ICW3, ICW4 commands using data port?
- A. It is parameter command type. ICW1 initialization command with ICW4 need, It will read data port 3 byte. ICW1 expect ICW2, ICW3, ICW4 sequence.

### Note IO Wait
- Q. Why using IO wait?
- A. CPU not wait automadicaly. And don't know PIC process status. So just wait for pysical process done timing. More safely.
- Q. How many IO wait time?
- A. Approximately 1 micro second.

---

## Reference Links
| Name | Description |
| --- | --- |
| External link: pic standard document | [OSDev: pic](https://wiki.osdev.org/8259_PIC) |

---

> Authors 2025 Facooya and Fanone Facooya
