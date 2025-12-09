# PS2 translate bit off
## Overview
Turn off translation bit in configuration byte. Translation bit is translate scan code set 2 to scan code set 1. Fayos using scan code set 2, Turn off translation bit.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `cli` - Disable interrupt

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Read configuration byte
1. Turn off translation bit
1. Write configuration byte

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: ps2](/docs/drv/ps2/README.md) |
| External link: standard document | [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller)

---

> Authors 2025 Facooya and Fanone Facooya
