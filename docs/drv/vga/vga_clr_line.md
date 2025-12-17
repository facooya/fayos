# VGA Clear Line
## Overview
Clear line for current cursor position.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `vga_get_curs()`
- `vga_set_curs()`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Get cursor position
1. Get screen column
1. Calculate for current line index
    - `current_cursor_pos / COLUMN = current_line_idx`
1. Calculate for current line start offset
    - `current_line_idx * COLUMN = current_line_start_off`
1. Point VGA memory for current line start offset
1. Set cursor for current line start offset
1. Clear line to write space
    - color attribute background=black, foreground=white

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |
| VGA get cursor | [docs: vga get cursor](/docs/drv/vga/vga_get_curs.md) |
| VGA set cursor | [docs: vga set cursor](/docs/drv/vga/vga_set_curs.md) |

---

> Authors 2025 Facooya and Fanone Facooya
