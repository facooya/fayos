# Header for PS2
## Overview
Definition for personal system 2.

> [!IMPORTANT]
> This document write for Fayos.
> So it is different to standard.

> [!NOTE]
> **You can find standard document here** [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller)

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
| `PS2_SC_EXT` | Scan code for extend |
| `PS2_SC_BRK` | Scan code for break |
| `PS2_SC_LSHF` | Scan code for left shift |
| `PS2_SC_RSHF` | Scan code for right shift |
| `PS2_SC_LCTL` | Scan code for left control |
| `PS2_SC_RCTL` | Scan code for right control |
| `PS2_SC_LALT` | Scan code for left alternate |
| `PS2_SC_RALT` | Scan code for right alternate |
| `PS2_SC_CAP` | Scan code for capital lock |
| `PS2_SC_UP` | Scan code for up arrow |
| `PS2_SC_DOWN` | Scan code for down arrow |
| `PS2_SC_LEFT` | Scan code for left arrow |
| `PS2_SC_RIGHT` | Scan code for right arrow |
| `PS2_SC_NUM_SL` | Scan code for slash in numpad |
| `PS2_SC_NUM_ENT` | Scan code for enter in numpad |

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

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: ps2](/docs/drv/ps2/README.md) |
| Register Map | [docs: ps2 register map](/docs/drv/ps2/README.md#register-map) |
| External link, PS2 standard document | [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller) |

---

> Authors 2025 Facooya and Fanone Facooya
