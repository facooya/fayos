BUILD = ./build

AS = as --32
LD_BOOT = ld --oformat binary -m elf_i386 -Ttext 0x7C00
LD_KERNEL = ld -m elf_i386 -T ./tools/linker.ld

# Don't reposition "kernel/kernel.s",
# This file always first location in Fayos.
# kernel_addr: segment:offset = 0x0000:0x1000
SRCS = \
kernel/kernel.s \
\
kernel/sys/_sys_disk.s \
kernel/sys/_sys_kbd.s \
kernel/sys/_sys_vid.s \
\
kernel/kbd/kbd_main.s \
kernel/kbd/kbd_lsh.s \
kernel/kbd/kbd_rsh.s \
\
kernel/kbd/_key_bs.s \
kernel/kbd/_key_cr.s \
kernel/kbd/_key_down.s \
kernel/kbd/_key_left.s \
kernel/kbd/_key_right.s \
kernel/kbd/_key_up.s \
\
kernel/io/buf.s \
kernel/io/cursor.s \
kernel/io/outs.s \
kernel/io/out_utils.s \
\
kernel/io/dap.s \
kernel/io/dap_utils.s \
kernel/io/disk.s \
kernel/io/set_dap_blk_lba.s \
\
kernel/dbg/dbg_args.s \
kernel/dbg/dbg_cursor.s \
kernel/dbg/dbg_buf.s \
kernel/dbg/dbg_trace.s \
kernel/dbg/dbg_utils.s \
\
kernel/dbg/num/dbg_num.s \
kernel/dbg/num/dbg_reg.s \
\
\
fs/cache.s \
\
fs/super/super.s \
fs/super/_super_alloc_lba.s \
fs/super/_super_make_root.s \
fs/super/_super_set_bitmap.s \
fs/super/_super_set_lba.s \
fs/super/_super_write_data.s \
\
fs/inode/add_inode.s \
fs/inode/clear_inode.s \
fs/inode/read_inode.s \
fs/inode/update_inode.s \
\
fs/dentry/add_dentry.s \
fs/dentry/lookup_dentry.s \
\
fs/bit/alloc_bit.s \
fs/bit/clear_bit.s \
fs/bit/set_bit.s \
\
\
shell/history.s \
\
shell/args/args.s \
shell/args/tok_args.s \
shell/args/build_args.s \
shell/args/parse_args.s \
\
shell/exec/exec_cmd.s \
shell/exec/exec_redir.s \
\
shell/cmd/cmd_map.s \
\
shell/cmd/sys/echo.s \
shell/cmd/sys/help.s \
shell/cmd/sys/clear.s \
\
shell/cmd/file/cat.s \
shell/cmd/file/rm.s \
shell/cmd/file/touch.s \
\
shell/cmd/dir/cd.s \
shell/cmd/dir/ls.s \
shell/cmd/dir/mkdir.s \
shell/cmd/dir/rmdir.s \
\
\
lib/err.s \
lib/re.s \
lib/vid.s \
\
lib/dir/get_bottom_dir.s \
lib/dir/rm_dir.s \
\
lib/file/parse_file_lines.s \
\
lib/err/emsg_common.s \
lib/err/emsg_io.s \
lib/err/emsg_syn.s \
\
lib/str/putf.s \
lib/str/putns.s \
lib/str/puts.s \
lib/str/put_utils.s \
lib/str/split.s \
lib/str/str.s \
lib/str/trim.s

OBJS = $(SRCS:%.s=$(BUILD)/%.o)

# ALL
all: $(BUILD)/fayos.img

$(BUILD)/fayos.img: $(BUILD)/boot.bin $(BUILD)/kernel.bin | $(BUILD)
	dd if=/dev/zero of=$(BUILD)/fayos.img bs=512 count=20480
	dd if=$(BUILD)/boot.bin of=$(BUILD)/fayos.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/kernel.bin of=$(BUILD)/fayos.img bs=512 seek=16 conv=notrunc

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
