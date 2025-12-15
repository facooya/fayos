# Boot
## Overview
Bootloader main for Fayos.
Display contol with direct VGA access memory.
Kernel sectors read with ATA PIO mode polling method.
Write the boot signature via linker script.

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
1. Clear interrupt and clear direction
1. Initialize registers to zero
    - init registers: `ax, ds, es, ss, sp, bp`
    - mandatory to zero: `ds, ss`
1. Set stack start address
    - `sp = 0x7C00`
1. Clear display
1. Print boot message
1. Read kernel sectors
1. Jump to kernel
    - `cs:ip = 0x0000:0x1000`

| Description | Link |
| --- | --- |
| Clear interrupt | [docs: cli](/docs/boot/README.md#note-clear-interrupt) |
| Clear Direction | [docs: cld](/docs/boot/README.md#note-clear-direction) |
| Stack work | [docs: stack](/docs/boot/README.md#note-stack) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Header for bootloader | [docs: boot header](/docs/inc/boot.md) |
| Main doucment for boot | [docs: boot](/docs/boot/README.md) |
| Main document for kernel | [docs: kernel](/docs/kern/README.md) |
| Main document for Fayos | [docs: fayos](/docs/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
