# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

# config
FAYOS_IMG = ./build/fayos.img
BOOT_BIN = ./build/boot.bin
KERN_BIN = ./build/kern.bin
TOT_SECT_CNT = 20480

# boot
SRC_BOOT = boot/boot.s
OBJ_BOOT = $(SRC_BOOT:%.s=./build/%.o)

# kernel
SRCS_KERN = \
kern/kernel.s \
kern/debug.s

# file system
SRCS_FS = \
fs/fs.s \
fs/superblock.s \
fs/bitmap.s \
fs/inode.s \
fs/dentry.s \
fs/path.s \
fs/fsp.s \

# shell
SRCS_SH = \
sh/cwd.s \
sh/args.s \
sh/prompt.s \
sh/execute.s \
sh/history.s \
\
sh/cmd/command.s \
sh/cmd/test.s \
sh/cmd/echo.s \
sh/cmd/date.s \
sh/cmd/help.s \
sh/cmd/clear.s \
sh/cmd/poweroff.s \
\
sh/cmd/cat.s \
sh/cmd/ls.s \
sh/cmd/pwd.s \
sh/cmd/cd.s \
sh/cmd/touch.s \
sh/cmd/rm.s \
sh/cmd/mkdir.s \
sh/cmd/rmdir.s

# driver
SRCS_DRV = \
drv/apm.s \
drv/ata.s \
drv/vga.s \
drv/ps2.s \
drv/rtc.s \
\
drv/disk.s \
drv/display.s \
drv/keyboard.s \
drv/time.s

# interrupt
SRCS_INT = \
int/interrupt.s \
int/isr.s

# library
SRCS_LIB = \
lib/error.s \
lib/regex.s \
lib/conversion.s \
lib/put.s \
lib/file.s \
lib/memory.s

# kernel group
SRCS_GROUP_KERN = \
$(SRCS_KERN) \
$(SRCS_FS) \
$(SRCS_SH) \
$(SRCS_DRV) \
$(SRCS_INT) \
$(SRCS_LIB)

# objects
OBJS_KERN = $(SRCS_GROUP_KERN:%.s=./build/%.o)

# { command
all: $(FAYOS_IMG)

$(FAYOS_IMG): $(BOOT_BIN) $(KERN_BIN) | ./build/
	dd if=/dev/zero of=$(FAYOS_IMG) bs=512 count=$(TOT_SECT_CNT)
	dd if=$(BOOT_BIN) of=$(FAYOS_IMG) bs=512 count=1 conv=notrunc
	dd if=$(KERN_BIN) of=$(FAYOS_IMG) bs=512 seek=16 conv=notrunc

$(BOOT_BIN): $(OBJ_BOOT) | ./build/
	ld -T ./boot/boot.lds -o $@ $^

$(KERN_BIN): $(OBJS_KERN) | ./build/
	ld -T ./kern/kern.lds -o $@ $^

$(OBJ_BOOT): $(SRC_BOOT) | ./build/
	mkdir -p $(dir $@)
	as --32 -Iboot -o $@ $^

./build/%.o: %.s | $(OBJ_BOOT)
	mkdir -p $(dir $@)
	as --32 -Iinc -o $@ $^

./build/:
	mkdir -p $@

clean:
	find ./build/ -name "*.bin" -delete
	find ./build/ -name "*.o" -delete
	find ./build/ -name "*.lock" -delete
	find ./build/ -name "bochslog" -delete
	find ./build/ -type d -empty -delete

clean_all: clean
	find ./build/ -name "*.img" -delete
	find ./build/ -type d -empty -delete
# }
