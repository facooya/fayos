# VGA Put Character
## Overview
Put character to screen.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `al = character`
- `vga_size`
- `vga_last_row_off`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Check escape characters
    - supports carriage return and line feed
1. Get cursor position
    - if cursor position is VGA size equal or over, jump shift up
1. Set cursor position for current cursor position + 1 (pre-update)
1. Put character

**Escape CR**
1. Get cursor position
1. Calculate current line start offset
    - `cursor_position - (cursor_position % COLUMN) = current_line_start_offset`
1. Set cursor position for current line start offset

**Escape LF**
1. Get cursor position
1. Cursor position value update for current cursor position + column
    - if `current_cursor_position + column` over or equal than screen size, jump shift up for line feed
1. Set cursor position for current cursor position + column

**Shift Up**
1. Rewrite like shift up
    - Like shift up: first line deleted -> second line move to first line -> third line move to second line -> ...
1. Clear last line
1. Set cursor position for last line offset + 1 (pre-update)
1. Put character


---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |
| VGA get cursor | [docs: vga get cursor](/docs/drv/vga/vga_get_curs.md) |
| VGA set cursor | [docs: vga set cursor](/docs/drv/vga/vga_set_curs.md) |

---

> Authors 2025 Facooya and Fanone Facooya
