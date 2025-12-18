# Display Shift Left in Command Line
## Overview
Screen shift left in command line. Useful delete character in command line.

---

## Table of Contents
- [API Reference](#api-reference)
- [Process Flow](#process-flow)
- [Reference Links](#reference-links)

---

## API Reference
### Parameters
1. `ub8 *data`
    - string type
    - point to `current_cursor_position - 1` in command line

### Requires
- `mem_size()`
- `vga_putc()`
- `vga_puts()`
- `vga_get_curs()`
- `vga_set_curs()`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Data position recalculate point to current cursor position
    - `&data + 1`
1. Get string tail size
1. Shift left data
    - repeat `(data+i) = chr; chr = (data+i-1);`
1. Get current cursor position, `pos - 1` for restore and update
1. Update cursor position for put string position
1. Update screen for shift left
    - auto increase cursor position
1. Remove last character from effect shift left
    - overwrite space to last character
1. Restore cursor position

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for display | [docs: display](/docs/drv/disp/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
