# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Keyboard constants

# Bit
.equ KBD_FLG_LSHF, (0x01<<0x00)
.equ KBD_FLG_RSHF, (0x01<<0x01)
.equ KBD_FLG_LCTL, (0x01<<0x02)
.equ KBD_FLG_RCTL, (0x01<<0x03)
.equ KBD_FLG_LALT, (0x01<<0x04)
.equ KBD_FLG_RALT, (0x01<<0x05)
.equ KBD_FLG_CAP, (0x01<<0x06)

# Keycode
.equ KBD_KC_EXT, 0xE0
.equ KBD_KC_LEFT, 0xE06B
.equ KBD_KC_RIGHT, 0xE074
.equ KBD_KC_UP, 0xE075
.equ KBD_KC_DOWN, 0xE072
.equ KBD_KC_NUM_SL, 0xE04A
.equ KBD_KC_NUM_ENT, 0xE05A
