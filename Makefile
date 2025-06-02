BUILD = ./build

AS = as --32
LD_BOOT = ld --oformat binary -m elf_i386 -Ttext 0x7C00
LD_KERNEL = ld -m elf_i386 -T ./tools/linker.ld

SRCS = \
kernel/kernel.s \
\
kernel/buf.s \
kernel/cache.s \
kernel/kbd.s \
kernel/args/args.s \
kernel/args/tok_args.s \
kernel/args/build_args.s \
kernel/args/parse_args.s \
kernel/exec/exec.s \
kernel/exec/exec_redir.s \
kernel/dbg/dbg_args.s \
kernel/dbg/dbg_buf.s \
kernel/dbg/dbg_trace.s \
kernel/dbg/dbg_utils.s \
kernel/io/outs.s \
kernel/io/out_utils.s \
\
sys/disk.s \
sys/kbd.s \
sys/vid.s \
\
lib/cursor.s \
lib/err.s \
lib/re.s \
lib/vid.s \
lib/disk/block.s \
lib/disk/dap.s \
lib/str/print.s \
lib/str/split.s \
lib/str/str.s \
lib/str/trim.s \
\
lib/put/puts.s \
\
fs/fayfs/alloc.s \
fs/fayfs/dir.s \
fs/fayfs/fayfs.s \
fs/fayfs/inode.s \
fs/fayfs/super.s \
\
cmd/sys/echo.s \
cmd/sys/help.s \
cmd/sys/clear.s \
\
cmd/file/cat.s \
cmd/file/rm.s \
cmd/file/touch.s \
\
cmd/dir/cd.s \
cmd/dir/ls.s \
cmd/dir/mkdir.s

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
