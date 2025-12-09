# PS2 check scan code set
## Overview
Check scan code set is 2. Generally keyboard using scan code set 2.

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
1. Disable interrupt from ps2
    - wait ack and read to clear
1. Get current scan code set
    - current scan code set write the data port
    - wait ack
    - get scan code set write the data port
    - wait ack
1. Read scan code set
1. Enable interrupt from ps2
    - wait ack read to clear

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: ps2](/docs/drv/ps2/README.md) |
| External link: standard document | [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller)

---

> Authors 2025 Facooya and Fanone Facooya
