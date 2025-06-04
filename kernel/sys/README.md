## Facooya System Layer Convention

> This document follows the terminology defined in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).  
> The following rules apply only to the system layer and **MUST NOT** be applied to other layers.  
> The system layer prioritizes performance above all else and **MAY** violate conventional calling conventions designed for safety and extensibility.  
> The system layer in Fayos sacrifices safety and extensibility for the sake of performance, and therefore **MUST** be accessed directly only by the `kernel/` and `lib/` layers to minimize the consequences of this design trade-off.

---

### 1. Stack operations MUST NOT be used

**1.1.** Exception: `call` for entering and `ret` for exiting an system function are permitted.

**1.2.** System functions **MUST NOT** preserve any registers.  
Callers **MUST** preserve any registers they require before calling an system function.

**1.2.1.** The `si` register is frequently used in disk-related interrupts, and `bx` is commonly used in video-related interrupts.  
Callers **SHOULD** check whether these registers are used and preserve them as necessary.

---

### 2. The `jmp` Instruction MUST NOT Be Used

**2.1.** The `jmp` instruction modifies the `ip` at runtime, resulting in an actual branch that degrades pipeline performance.  

**2.1.1.** Although `jmp` can reduce code size, the system layer prioritizes performance above all else and therefore forbids its use despite the size benefit.  

**2.2.** Functions in the system layer are typically short and easy to read even when duplicated.  
For this reason, they **SHOULD** be written in a duplicated form to maintain performance consistency and simplicity.  

**2.2.1.** If code duplication becomes a burden, macros **MAY** be used instead.  
Macros are expanded at assembly time, and their performance is equivalent to that of code duplication.  

---

### 3. Zero initialization MUST be done with `xor` instruction

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

---

### 4. Prefixes MUST use `sys_*`

**4.1.** This prefix is intended to clearly indicate that the code violates established conventions.  

---

### Note

We didn't prohibit everything explicitly.
However, any code that tries to circumvent the intent of this document is not so much exploiting a loophole,
as it is diving headfirst into it.  

A typical example would be:
```asm
xor %ax, %ax  
test %ax, %ax  
jz jump_label
```

You might be thinking,
"Well, the rule only forbids `jmp`, not `jz`, right?"
But as you probably know, `jz` is still, in practice, a type of `jmp`.
It performs worse and completely misses the point. :(  

If you're going to twist the rule to follow it, just break it.
It's better to break the rule than to bend it trying to keep it.
We warned you. The choice is yours. :)  
