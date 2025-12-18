# Display Shift Right in Command Line
## Overview
Screen shift right in command line.

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
    - point to `current_cursor_position + 1` in command line
1. `ub8 ascii`
    - insert character to `current_cursor_position`

### Requires
- `mem_size()`
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
    - `&data - 1`
1. Get string tail size
1. Point to last string
1. Shfit right data
    - repeat `(data+i) = chr; chr = (data+i+1);`
1. Insert character in data
    - data position: current cursor position
1. Get current cursor position for restore
1. Screen update for shift right
    - effect auto increase cursor position using `vga_puts()`
1. Restore cursor position and plus 1
1. Update cursor position

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for display | [docs: display](/docs/drv/disp/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
