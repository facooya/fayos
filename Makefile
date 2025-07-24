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
kernel/args/args.s \
kernel/args/tok_args.s \
kernel/args/build_args.s \
kernel/args/parse_args.s \
\
kernel/cli/cli_main.s \
kernel/cli/cli_lsh.s \
kernel/cli/cli_rsh.s \
\
kernel/cli/cli_key_bs.s \
kernel/cli/cli_key_cr.s \
kernel/cli/cli_key_down.s \
kernel/cli/cli_key_left.s \
kernel/cli/cli_key_right.s \
kernel/cli/cli_key_up.s \
\
kernel/exec/exec_cmd.s \
kernel/exec/exec_redir.s \
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
kernel/sys/_sys_disk.s \
kernel/sys/_sys_kbd.s \
kernel/sys/_sys_vid.s \
\
fayfs/fayfs.s \
\
fayfs/bit/alloc_bit.s \
fayfs/bit/clear_bit.s \
fayfs/bit/set_bit.s \
\
fayfs/dentry/add_dentry.s \
fayfs/dentry/lookup_dentry.s \
\
fayfs/inode/add_inode.s \
fayfs/inode/clear_inode.s \
fayfs/inode/read_inode.s \
fayfs/inode/update_inode.s \
\
fayfs/super/super.s \
fayfs/super/_super_alloc_lba.s \
fayfs/super/_super_make_root.s \
fayfs/super/_super_set_bitmap.s \
fayfs/super/_super_set_lba.s \
fayfs/super/_super_write_data.s \
\
lib/err.s \
lib/re.s \
lib/vid.s \
\
lib/dir/get_bottom_dir.s \
lib/dir/rm_dir.s \
\
lib/err/emsg_common.s \
lib/err/emsg_io.s \
lib/err/emsg_syn.s \
\
lib/str/putf.s \
lib/str/puts.s \
lib/str/put_utils.s \
lib/str/split.s \
lib/str/str.s \
lib/str/trim.s \
\
cmd/cmd_map.s \
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
cmd/dir/mkdir.s \
cmd/dir/rmdir.s

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
