# Keyboard Process
## Overview
Normal keycode handler and special key dispatcher.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `al = keycode`

### Modifies
- `cl_sbuf`
- `curs`

### Returns
- `N/A`

---

## Process Flow
1. Dispatch for spcial keys
    - if special key, jump to ecah key handler
1. Pre-update command line buffer
    - update +1 for buffer pointer and size
1. Pre-update cursor structure for maximum
1. Check null of current cursor position -1
    - not null, screen shift right in command line (insert mode)
1. Put character in screen
1. Write data in command line buffer
    - Write to buffer pointer -1

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `cl_sbuf`, `curs` | [docs: kern data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
