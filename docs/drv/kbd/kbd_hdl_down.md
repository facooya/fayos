# Keyboard Handle Down
## Overview
Keyboard handler for down arrow key. Related history function.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `cl_hist_sbuf`
- `file_lines`

### Modifies
- `cl_sbuf`
- `hist_idx`
- `curs`

### Returns
- `si = cl_sbuf + last_index`

---

## Process Flow
1. Compare history index with history file line count
    - done if equal, as history index already first
1. Update history index + 1
1. Compare history index with history file line count
    - jump to load if equal
1. Update screen and command line buffer by history function
1. Update command line buffer pointer

**Load**
1. Initial command line buffer to zero
    - prevent for bug
1. Copy history buffer to command line buffer
1. Update screen
1. Clear current line on screen
1. Update screen for prompt string
1. Initial cursor structure for prompt string
1. Update screen for command line
1. Update cursor structure for maximum

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `cl_sbuf`, `cl_hist_sbuf` | [docs: kernel data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
