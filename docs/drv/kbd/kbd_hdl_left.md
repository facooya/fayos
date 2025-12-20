# Keyboard Handle Left
## Overview
Keyboard handler for left arrow key.

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
- `si = {normal: cl_sbuf + index - 1}, {skip: cl_sbuf + index}`

---

## Process Flow
1. Get current cursor position
1. Skip if current cursor position x value equal cursor strucutre minimun value
1. Set cursor position -1
1. Update command line buffer index -1

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `curs` | [docs: kernel data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
