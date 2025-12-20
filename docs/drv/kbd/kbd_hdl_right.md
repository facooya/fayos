# Keyboard Handle Right
## Overview
Keyboard handler for right arrow key.

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
- `si = cl_sbuf + index`
- `curs`

### Modifies
- `N/A`

### Returns
- `si = {normal: cl_sbuf + index + 1}, {skip: cl_sbuf + index}`

---

## Process Flow
1. Get current cursor position
1. Compare maximum cursor value with current cursor value
    - done if equal
1. Set cursor position + 1
1. Update for command line buffer index + 1

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `curs` | [docs: kernel data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
