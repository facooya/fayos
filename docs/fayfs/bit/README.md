# Bit
## Allocate Bit
Summary:
```c
uint16_t alloc_bit(uint16_t *mem) { // bx

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
  uint16_t bitnum = 0;
  bitnum = word_count * 16;
  bitnum += bit_count;

  return bitnum; // ax // TODO: dx:ax
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
```

---

## Set Bit
Summary:
```c
```

---

> Authors: Facooya and Fanone Facooya
