# Interrupt Header
## Overview
Header for interrupt.

---

## Table of Contents
- [Constants](#constants)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Constants
**Common**
| Name | Description |
| --- | --- |
| `EOI` | End of interrupt |
| `IO_WAIT` | Delay 1 micro second |

**Port**
| Name | Description |
| --- | --- |
| `PIC1_PORT_CMD` | Command port for PIC1 |
| `PIC1_PORT_DATA` | Data port for PIC1  |
| `PIC2_PORT_CMD` | Command port for PIC2 |
| `PIC2_PORT_DATA` | Data port for PIC2 |

**ICW**
| Name | Description |
| --- | --- |
| `ICW1_ICW4` | Need utill ICW4 bit for command |
| `ICW1_INIT` | Initialization bit for command |
| `ICW2_PIC1` | Base vector index for PIC1 |
| `ICW2_PIC2` | Base vector index for PIC2 |
| `ICW3_PIC1_PIC2` | IRQ2 (PIC2) bit in PIC1 |
| `ICW3_PIC2_IDX` | Index for PIC2 (IRQ2) |
| `ICW4_8086` | CPU mode |

**IMR**
| Name | Description |
| --- | --- |
| `IMR_IRQ_ALL` | Select to All |
| `IMR_IRQ1` | Select to IRQ1 |
| `IMR_IRQ2` | Select to IRQ2 |
| `IMR_IRQ8` | Select to IRQ8 |
| `IMR_IRQ14` | Select to IRQ14 |

**IVT**
| Name | Description |
| --- | --- |
| `IVT_ENT_IRQ1` | Vector entry for PS2 |
| `IVT_ENT_IRQ8` | Vector entry for RTC |
| `IVT_ENT_IRQ14` | Vector entry for ATA |

---

## Terms
| Name | Description |
| --- | --- |
| EOI | End of Interrupt |
| ICW | Initialization Command Words |
| IMR | Interrup Mask Register |
| IRQ | Interrupt Request |
| IVT | Interrupt Vector Table |
| PIC | Programmable Interrupt Controller |
| ENT | Entry |

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for interrupt | [docs: interrupt](/docs/int.md) |
| External link, PIC standard document | [OSDev: pic](https://wiki.osdev.org/8259_PIC) |
| External link, IVT standard document | [OSDev: ivt](https://wiki.osdev.org/Interrupt_Vector_Table) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
