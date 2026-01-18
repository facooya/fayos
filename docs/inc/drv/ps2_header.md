# PS2 Header
## Overview
Header for PS2.

---

## Table of Contents
- [Constants](#constants)
- [Macro](#macro)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Constants
**Common**
| Name | Description |
| --- | --- |
| `PS2_ACK` | Acknowledge, Signal from data. |
| `PS2_RESEND` | Resend, Signal from data. |

**Port**
| Name | Description |
| --- | --- |
| `PS2_PORT_DATA` | Data |
| `PS2_PORT_STAT` | Status |
| `PS2_PORT_CMD` | Command |

**Command**
| Name | Description |
| --- | --- |
| `PS2_CMD_READ_CONF` | Read configuration byte |
| `PS2_CMD_Write_CONF` | Write configuration byte |
| `PS2_DATA_DISABLE_SCAN` | Data command, Disable scan |
| `PS2_DATA_ENABLE_SCAN` | Data command, Enable scan |
| `PS2_DATA_GET_SET_SCS` | Data command, Get or set scan code set |
| `PS2_DATA_GET_SCS` | Data command, Get scan code set. Mandatory write `PS2_DATA_GET_SET_SCS` before write this command.  |

**Scan Code**
| Name | Description |
| --- | --- |
| `PS2_SC_EXT` | Scancode for extend |
| `PS2_SC_BRK` | Scancode for break |
| `PS2_SC_LSHF` | Scancode for left shift |
| `PS2_SC_RSHF` | Scancode for right shift |
| `PS2_SC_LCTL` | Scancode for left control |
| `PS2_SC_RCTL` | Scancode for right control |
| `PS2_SC_LALT` | Scancode for left alternate |
| `PS2_SC_RALT` | Scancode for right alternate |
| `PS2_SC_CAP` | Scancode for capital lock |
| `PS2_SC_UP` | Scancode for up arrow |
| `PS2_SC_DOWN` | Scancode for down arrow |
| `PS2_SC_LEFT` | Scancode for left arrow |
| `PS2_SC_RIGHT` | Scancode for right arrow |
| `PS2_SC_NUM_SL` | Scancode for slash in numpad |
| `PS2_SC_NUM_ENT` | Scancode for enter in numpad |
| `PS2_SC_INS` | Scancode for insert |
| `PS2_SC_DEL` | Scancode for delete |
| `PS2_SC_HOME` | Scancode for home |
| `PS2_SC_END` | Scancode for end |
| `PS2_SC_PAGE_UP` | Scancode for page up |
| `PS2_SC_PAGE_DOWN` | Scancode for page down |

**Bit**
| Name | Description |
| --- | --- |
| `PS2_OBF` | Bit for output buffer full |
| `PS2_IBF` | Bit for input buffer full |
| `PS2_CONF_XLATE` | Translation bit in configuration byte |
| `PS2_SCF_BRK` | Break bit for scan code flag |
| `PS2_SCF_EXT` | Extend bit for scan code flag |

---

## Macro
| Name | Description |
| --- | --- |
| `IBF` | Input Buffer Full, Ready to write, If 0 end. |
| `OBF` | Output Buffer Full, Ready to read, If 1 end. |

---

## Terms
| Name | Description |
| --- | --- |
| PS2 | Personal System 2 |
| OBF | Output Buffer Full |
| IBF | Input Buffer Full |
| SC | Scancode |
| SCF | Scancode Flag |
| SCS | Scancode Set |
| XLATE | Translate |

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for PS2 | [docs: ps2](/docs/drv/ps2.md) |
| Directory document for include | [docs: dir include](/docs/inc/README.md) |
| External link, PS2 standard document | [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
