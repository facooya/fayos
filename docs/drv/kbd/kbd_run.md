# Keyboard Run
## Overview
Keybarod run function, call only in kernel main loop.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `scancode`

### Returns
- `N/A`

---

## Process Flow
1. Update modifier flag
1. Pre done, if scancode break status or set/clear modifier flag
1. Convert to keycode from scancode
1. Update screen
1. Initial scancode to zero

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `scancode` | [docs: kern data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
