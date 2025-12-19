# Keyboard Convert Keycode
## Overview
Convert scancode to keycode.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `scancode`
- `kbd_mflg`

### Modifies
- `N/A`

### Returns
- `al = keycode`

---

## Process Flow
1. Chekc extend key
    - if extend key, jump extend logic
1. Select keymap
    - if left/right shift pressed, replace keymap shift
1. Convert to keycode refer for keymap

**Capitals Lock**
1. Check for shift key pressed
    - if left/right shift pressed, jump capitals lock shift logic
1. Convert keycode refer for normal keymap
1. Check regular expression for keycode `[a-z]`
    - true, convert keycode lowercase to uppercase
    - false, pass current keycode

**Capitals Lock Shift**
1. Convert keycode refer for keymap shift mode
1. Check regular expression for keycode `[A-Z]`
    - true, convert keycode uppercase to lowercase
    - false, pass current keycode

**Extend**
1. Convert keycode refer for extend header

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for keyboard | [docs: keyboard](/docs/drv/kbd/README.md) |
| Data definition for `scancode` | [docs: kern data](/docs/kern/kern_data.md) |
| Data definition for `kbd_mflg` | [docs: kbd data](/docs/drv/kbd/kbd_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
