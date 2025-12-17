# VGA Put String
## Overview
Put string to screen. Supports carriage return and line feed.

---

## API Reference
### Parameters
1. `ub8 *str`

### Requires
- `vga_size`
- `vga_last_row_off`
- `vga_get_curs()`
- `vga_set_curs()`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Get current cursor position
1. Put string to screen
    - check escape character
    - if current cursor position over or equal, jump to **shift up inner**
1. Set cursor position

**Carriage Return**
1. Calculate for current line start offset
    - `cursor_pos - (cursor_pos % COLUMN) = current_line_start_off`
1. Go back to keep put string to screen

**Line Feed**
1. Calculate next line offset and set VGA memory for next line offset
    - `current_cursor_position + COLUMN = next_line_offset`
1. Go back to keep put string to screen
    - if current cursor position over or equal, jump to **shift up**

**Shift Up Inner**
1. Overwrite like shift up
    - Like shift up: first line deleted -> second line move to first line -> third line move to second line -> ...
1. Clear last line
1. Update cursor position cache and set VGA memory
1. Go back to keep put string to screen

**Shift Up**
1. Update cursor position cache (pre-update)
1. Overwrite like shift up
1. Clear last line
    - overwrite space
1. Update cursor position cache and set VGA memory
1. Go back to keep put string to screen

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |
| VGA get cursor | [docs: vga get cursor](/docs/drv/vga/vga_get_curs.md) |
| VGA set cursor | [docs: vga set cursor](/docs/drv/vga/vga_set_curs.md) |

---

> Authors 2025 Facooya and Fanone Facooya
