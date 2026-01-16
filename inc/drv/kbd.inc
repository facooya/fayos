# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

# modifier flag
.equ KBD_MFLG_LSHF, (0x01<<0x00)
.equ KBD_MFLG_RSHF, (0x01<<0x01)
.equ KBD_MFLG_LCTL, (0x01<<0x02)
.equ KBD_MFLG_RCTL, (0x01<<0x03)
.equ KBD_MFLG_LALT, (0x01<<0x04)
.equ KBD_MFLG_RALT, (0x01<<0x05)
.equ KBD_MFLG_CAP, (0x01<<0x06)

# { keycode
# 0xE0-0xEF
.equ KBD_KC_UP, 0xE0
.equ KBD_KC_DOWN, 0xE1
.equ KBD_KC_LEFT, 0xE2
.equ KBD_KC_RIGHT, 0xE3
.equ KBD_KC_NUM_SL, 0xE4
.equ KBD_KC_NUM_ENT, 0xE5
.equ KBD_KC_HOME, 0xD2
.equ KBD_KC_END, 0xD3
.equ KBD_KC_PAGE_UP, 0xD4
.equ KBD_KC_PAGE_DOWN, 0xD5

# 0xF0-0xFF
.equ KBD_KC_F1, 0xF1
.equ KBD_KC_F2, 0xF2
.equ KBD_KC_F3, 0xF3
.equ KBD_KC_F4, 0xF4
.equ KBD_KC_F5, 0xF5
.equ KBD_KC_F6, 0xF6
.equ KBD_KC_F7, 0xF7
.equ KBD_KC_F8, 0xF8
.equ KBD_KC_F9, 0xF9
.equ KBD_KC_F10, 0xFA
.equ KBD_KC_F11, 0xFB
.equ KBD_KC_F12, 0xFC
.equ KBD_KC_TAB, 0xFE
.equ KBD_KC_ESC, 0xFF
# }
