# Keyboard Update Modifier Flag
## Overview
Modifier key flag set/clear function. Flag size is 2-byte.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `scancode`
- `kbd_mflg`

### Returns
- `ax = {0:skip}`

---

## Process Flow
1. Check extend key
    - no extend, update scancode header to zero
    - extend, update scancode header to extend scancode value
1. Check break flag for scancode
    - no break, jump set flag
    - break, jump clear flag

**Set flag**
1. Check modifier keys
    - if no modifier key pressed, done with not skip `ax != 0`
1. Set modifier flag
    - done with skip `ax = 0`

**Clear flag**
1. Check modifier keys
    - if no modifier key released, done with skip `ax = 0`
1. Clear modifier flag
    - done with skip `ax = 0`

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `scancode` | [docs: kern data](/docs/kern/kern_data.md) |
| Data definition for `kbd_mflg` | [docs: kbd data](/docs/drv/kbd/kbd_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
