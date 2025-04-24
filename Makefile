BUILD = ./build

AS = as --32
LD_BOOT = ld --oformat binary -m elf_i386 -Ttext 0x7C00
LD_KERNEL = ld -m elf_i386 -T ./tools/linker.ld

SRCS = \
kernel/kernel.s \
kernel/cache.s \
kernel/args.s \
kernel/exec.s \
kernel/kbd.s \
\
sys/disk.s \
sys/kbd.s \
sys/vid.s \
\
lib/block.s \
lib/cursor.s \
lib/err.s \
lib/print.s \
lib/split.s \
lib/strlen.s \
lib/trim.s \
lib/vid.s \
\
lib/put/out.s \
lib/put/puts.s \
\
fs/fayfs/super.s \
fs/fayfs/dir.s \
fs/fayfs/meta.s \
fs/fayfs/alloc.s \
\
cmd/sys/echo.s \
cmd/sys/help.s \
cmd/sys/clear.s \
\
cmd/file/cat.s \
cmd/file/ls.s \
cmd/file/touch.s \
cmd/file/rm.s \
\
cmd/dir/mkdir.s \
cmd/dir/cd.s

OBJS = $(SRCS:%.s=$(BUILD)/%.o)

# ALL
all: $(BUILD)/fayos.img

$(BUILD)/fayos.img: $(BUILD)/boot.bin $(BUILD)/kernel.bin | $(BUILD)
	dd if=/dev/zero of=$(BUILD)/fayos.img bs=512 count=2880
	dd if=$(BUILD)/boot.bin of=$(BUILD)/fayos.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/kernel.bin of=$(BUILD)/fayos.img bs=512 seek=32 conv=notrunc

$(BUILD)/boot.bin: ./boot/boot.s | $(BUILD)
	$(AS) ./boot/boot.s -o $(BUILD)/boot.o
	$(LD_BOOT) $(BUILD)/boot.o -o $(BUILD)/boot.bin

$(BUILD)/kernel.bin: $(OBJS) | $(BUILD)
	$(LD_KERNEL) $(OBJS) -o $(BUILD)/kernel.bin

$(BUILD)/%.o: %.s | $(BUILD)
	mkdir -p $(dir $@)
	$(AS) -Iinclude $< -o $@

$(BUILD):
	mkdir -p $@

# CLEAN
clean:
	find $(BUILD) -name "*.bin" -delete
	find $(BUILD) -name "*.o" -delete
	find $(BUILD) -type d -empty -delete

clean_all: clean
	find $(BUILD) -name "*.img" -delete
	find $(BUILD) -type d -empty -delete
