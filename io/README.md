## Facooya I/O Layer Convention

> This document follows the terminology defined in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).  
> The following rules apply only to the I/O layer and **MUST NOT** be applied to other layers.

---

### 1. Stack operations MUST NOT be used

**1.1.** Exception: `call` for entering and `ret` for exiting an I/O function are permitted.

**1.2.** I/O functions **MUST NOT** preserve any registers.  
Callers **MUST** preserve any registers they require before calling an I/O function.

**1.2.1.** The `si` register is frequently used in disk-related interrupts, and `bx` is commonly used in video-related interrupts.  
Callers **SHOULD** check whether these registers are used and preserve them as necessary.

---

### 2. Branch instructions MUST NOT be used

**2.1.** I/O functions MUST NOT use `jmp` to branch to other functions or labels.  
The `jmp` instruction modifies the `ip` at runtime, which results in an actual branch in the final executable and may affect pipeline performance.  
In contrast, macros are expanded at assembly time without modifying the `ip`, making them faster and more efficient.  
If you want to avoid code duplication, you SHOULD use macros instead of `jmp`.

!!! TODO check

---

### 3. Zero initialization MUST be done with xor instruction

**3.1.** The `xor` instruction is functionally equivalent to `mov $CONST_ZERO, %ax`,  
but `xor %ax, %ax` encodes to `31 C0` (2 bytes), whereas `mov $CONST_ZERO, %ax` encodes to `B8 00 00` (3 bytes),  
making `xor` more efficient in both size and performance.  

**3.1.1.** If both the high and low parts of a register must be cleared to zero, you **MUST** use the full register with `xor`.  
The instruction `xor %ax, %ax` encodes to `31 C0` (2 bytes),  
while `xor %al, %al` and `xor %ah, %ah` encode to `30 C0` and `30 E4` respectively, totaling 4 bytes.  
Using the full register is both semantically clearer and more efficient in size and performance.  

**3.2.** If a constant representing zero is defined, a comment identifying the constant name **SHOULD** be placed near the `xor` instruction.  

**3.2.1.** A constant with the value `0x00` **SHOULD** still be defined using `.equ`,  
even though it will not be used directly due to the use of `xor` for zero initialization.  
This has no impact on performance, as the constant is not included in the final instruction encoding.  

### 4. Prefix MUST use io_

**4.1.** Not yet
!!! TODO
