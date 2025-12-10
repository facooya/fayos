# ISR for PS2
## Overview
Invoke every bytes from key press or release scan code. Using IRQ 1 line. Example for invoke situation: If release left arrow, 1. 0xF0 (break), 2. 0xE0 (extend), 3. 0x6B (normal). So invoke interrupt 3 times for one key release.

---

## Interrupt Reference
### Invoke
- Every bytes from key press or release scan code

### Modifies
- `scan_code`

| Description | Link |
| --- | --- |
| Definition to `scan_code` | [docs: kernel data](/docs/kern/kern_data.md) |

---

## Process Flow
1. Check `init_flag`
    - If set, read dummy data and jump EOI
1. Read data
1. Check data
    - data type: break, extend, normal
1. Write in `scan_code`
    - According to data type
1. End of interrupt

| Description | Link |
| --- | --- |
| Definition to `scan_code` or `init_flag` | [docs: kernel data](/docs/kern/kern_data.md) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for PS2 | [docs: ps2](/docs/drv/ps2/README.md) |
| Definition to `scan_code` | [docs: kernel data](/docs/kern/kern_data.md) |
| External link, PS2 standard document | [OSDev: ps2](https://wiki.osdev.org/I8042_PS/2_Controller) |

---

> Authors 2025 Facooya and Fanone Facooya
