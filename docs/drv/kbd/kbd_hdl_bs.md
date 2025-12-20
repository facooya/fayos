# Keyboard Handle Backspace
## Overview
Keryboard hander for backspace key.

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
- `cl_sbuf`
- `curs`

### Returns
- `si = &cl_sbuf - 1`

---

## Process Flow
1. Get current cursor position
1. Compare current cursor x with cursor structure minimum
    - done if equal
1. Pre-update cursor strcuture maximun -1
1. Pre-update command line buffer data pointer -1
1. Pre-update command line buffer size -1
1. Null test for data pointer +1
    - jump for call display shift left and done if not null
1. Set cursor to current cursor position -1
1. Over wirte space
    - auto increase cursor
1. Set cursor to current cursor position -1
1. Store null in command buffer data

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `cl_sbuf`, `curs` | [docs: kernel data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
