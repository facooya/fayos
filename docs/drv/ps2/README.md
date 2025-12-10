# Readme for PS2
## Overview
The documents for Fayos.
This document for PS2 (Personal System 2).

**Implementation**
- Interrupt
- Translate off
- Scan code set 2

---

## Table of Contents
- [Module Map](#module-map)
- [Register Map](#register-map)
- [Terms](#terms)
- [Notes](#notes)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Link |
| --- | --- |
| PS2 initialization | [docs: ps2 init](/docs/drv/ps2/README.md) |
| PS2 translation bit off | [docs: ps2 xlate off](/docs/drv/ps2/ps2_xlate_off.md) |
| PS2 check scan code set 2 | [docs: ps2 chk sc set](/docs/drv/ps2/ps2_chk_sc_set.md) |
| Header for PS2 | [docs: ps2 header](/docs/inc/drv/ps2.md) |
| Interrupt service routine for PS2 | [docs: isr ps2](/docs/int/isr_ps2.md) |

---

## Register Map
> [!IMPORTANT]
> This register map write for Fayos.
> So table is different to standard.

> [!NOTE]
> **You can find standard document here** [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller)

**Port**
| Name | Port | Byte | Mode |
| :--- | :---: | :---: | :---: |
| Data | 0x60 | 1 | IO |
| Status | 0x64 | 1 | IN |
| Command | 0x64 | 1 | OUT |

**Status**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 0 | Output Buffer Full | 0=empty, 1=full | 1 is ready to read data or command. |
| 1 | Input Buffer Full | 0=empty, 1=full | 0 is ready to write data or command. |

**Configuration Byte**
| Bit | Name | Value | Description |
| :---: | --- | --- | --- |
| 6 | Configuration translation | 0=disable, 1=enable | Translation bit in configuration byte. If translate enable scan code set 2 convert to scan code set 1. |

---

## Terms
**Abbreviation**
- PS2: Personal System 2
- OBF: Output Buffer Full
- IBF: Input Buffer Full
- SC: Scan Code
- SCF: Scan Code Flag
- SCS: Scan Code Set
- KC: Key Code

**Word**
- ACK: Acknowledge
- STAT: status
- BRK: break
- EXT: extend
- XLATE: translate
- CMD: command
- CONF: configuration

**Key name**
- LSHF: left shift
- RSHF: right shift
- LCTL: left control
- RCTL: right control
- LALT: left alternate
- RALT: right alternate
- CAP: capitals lock
- NUM: Number pad

---

## Notes
### Note Data Command
- Q. What is data command?
- A. Normal command into I8042 chip. But data command into device.

---

## Reference Links
| Description | Link |
| --- | --- |
| PS2 initialization | [docs: ps2 init](/docs/drv/ps2/README.md) |
| PS2 translation bit off | [docs: ps2 xlate off](/docs/drv/ps2/ps2_xlate_off.md) |
| PS2 check scan code set 2 | [docs: ps2 chk sc set](/docs/drv/ps2/ps2_chk_sc_set.md) |
| Keyboard driver main document | [docs: keyboard](/docs/drv/kbd/README.md) |
| External link: PS2 standard document | [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller) |

---

> Authors 2025 Facooya and Fanone Facooya
