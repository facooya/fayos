# Bit
## Allocate Bit
Summary:
```c
void alloc_bit(uint16_t *mem, uint16_t *bitnum) { // bx

  /* .chk_word */
  uint16_t word_count = 0; // dx
  uint16_t mem_value = 0; // ax
  while(1) {
    mem_value = *mem;
    /* 16-bit is not full */
    if (mem_value != 0xFFFF) { break; }
    mem += 2;
    word_count++;
  }

  /* .chk_bit */
  uint16_t bit_count = 0; // cx
  while(1) {
    /* find free bit */
    if ((mem_value & (1 << bit_count)) == 0) { break; }
    bit_count++;
  }

  /* .chk_bit__end (calc bitnum) */
  uint16_t bitnum_calc = 0;
  bitnum_calc = word_count * 16;
  bitnum_calc += bit_count;

  *bitnum = bitnum_calc
}
```

Note:
```
mem_value = 0b00001111

// . = shift here
mem_value & (1 << 3) = 0b00001111 AND 0b0000.1000 = 0b00001000 = 8
mem_value & (1 << 4) = 0b00001111 AND 0b000.10000 = 0b00000000 = 0
```

---

## Clear Bit
Summary:
```c
void clear_bit(uint16_t *mem, uint16_t *bitnum) {
  uint16_t word_count = *bitnum / 16; // ax
  uint16_t bit_count = *bitnum % 16; // dx

  /* align 2 bytes */
  mem += word_count * 2 // bx

  uint16_t mem_value = *mem;
  mem_value &= ~(1 << bit_count);
  *mem = mem_value;
}
```

Note:
```
mem_value & ~(1 << 3) = 0b11111111 AND ~(0b00001000) = 0b11111111 AND 0b11110111 = 0b11110111
```

---

## Set Bit
Summary:
```c
void set_bit(uint16_t *mem, uint16_t *bitnum) {
  uint16_t word_count = *bitnum / 16; // ax
  uint16_t bit_count = *bitnum % 16; // dx

  /* align 2 bytes */
  mem += word_count * 2 // bx

  uint16_t mem_value = *mem;
  mem_value |= (1 << bit_count);
  *mem = mem_value;
}
```
Note:
```
mem_value | (1 << 3) = 0b00000111 OR 0b00001000 = 0b00001111
```

---

> Authors: Facooya and Fanone Facooya
