# VGA Get Cursor
## Overview
Get current cursor position.

---

## Table of Contents
- [API Reference](#api-reference)
- [Process Flow](#process-flow)
- [Reference Links](#reference-links)

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `N/A`

### Returns
- `ax = position`
    - `position / COLUMN = y`
    - `position % COLUMN = x`

---

## Process Flow
1. Get high/low value from memory and store return register

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |
| External link: standard document for cursor | [OSDev: cursor](http://wiki.osdev.org/Text_Mode_Cursor) |

---

> Authors 2025 Facooya and Fanone Facooya
