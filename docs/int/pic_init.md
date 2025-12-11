# PIC Initialization
## Overview
Initialization for PIC (Programmable Interrupt Controller).

---

## Table of Contents
- [API Reference](#api-reference)
- [Process Flow](#process-flow)
- [Reference Links](#reference-links)

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. ICW1: Initialization command with wait ICW4
    - command port (pic1 and pic2)
1. ICW2: remapping
    - data port (pic1 and pic2)
1. ICW3: connect
    - data port (pic1 and pic2)
1. ICW4: select cpu mode
    - data port (pic1 and pic2)
    - ICW1 initialization command done
1. OCW1: enable for using irq lines
    - data port (pic1 or pic2)

| Description | Link |
| --- | --- |
| Why using data port | [docs: int](/docs/int/README.md#note-data-port) |
| Why IO wait | [docs: int](/docs/int/README.md#note-io-wait) |
| Why remap | [docs: int](/docs/int/README.md#note-remap) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for interrupt | [docs: int](/docs/int/README.md) |
| External link: pic standard document | [OSDev: pic](https://wiki.osdev.org/8259_PIC) |

---

> Authors 2025 Facooya and Fanone Facooya
