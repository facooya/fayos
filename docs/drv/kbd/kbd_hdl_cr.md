# Keyboard Handle Carrage Return
## Overview
Keryboard hander for carrage return (enter) key.

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

### Returns
- `si = &cl_sbuf.data`

---

## Process Flow
1. Call execute command function
1. Update screen for prompt string
1. Initial cursor structure for prompt string
1. Initial command line buffer to zero
1. Update pointer for command line buffer

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `cl_sbuf` | [docs: kernel data](/docs/kern/kern_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
