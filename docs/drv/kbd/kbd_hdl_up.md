# Keyboard Handle Up
## Overview
Keyboard handler for up arrow key. Related history function.

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
- `file_lines`

### Modifies
- `cl_sbuf`
- `cl_hist_sbuf`
- `hist_idx`

### Returns
- `si = &cl_sbuf.data + last_index`

---

## Process Flow
1. Compare histroy index with 0
    - done if 0
1. Compare history index with history file line count
    - jump to save buffer if equal
1. Decrease history index
1. Update screen and command line buffer by history function

**Save**
1. Update history index - 1
1. Initial history buffer to zero
    - prevent for bug
1. Copy command line buffer to history buffer
1. Update screen and command line buffer by history function
1. Update command line buffer pointer

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `cl_sbuf`, `cl_hist_sbuf` | [docs: kernel data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
