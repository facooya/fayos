# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

# config
FAYOS_IMG = ./build/fayos.img
BOOT_BIN = ./build/boot.bin
KERN_BIN = ./build/kern.bin
TOT_SECT_CNT = 20480

# boot group
SRCS_GROUP_BOOT = \
boot/boot.s \
boot/boot_vga_puts.s \
boot/boot_vga_clr.s \
boot/boot_ata_read_sect.s

# kernel
SRCS_KERN = \
kern/kern.s \
kern/kern_data.s \
\
kern/mem/mem_data.s \
kern/mem/mem_alloc.s \
kern/mem/mem_free.s \
\
kern/dbg/dbg_arg_ccv.s \
kern/dbg/dbg_path_cv.s \
kern/dbg/dbg_curs.s \
kern/dbg/dbg_sbuf.s \
kern/dbg/dbg_trace.s \
kern/dbg/dbg_utils.s \
kern/dbg/dbg_fsp.s \
\
kern/dbg/num/dbg_num.s \
kern/dbg/num/dbg_reg.s

# file system
SRCS_FS = \
fs/fs_data.s \
fs/fs_open.s \
fs/fs_add.s \
fs/fs_rm.s \
fs/fs_path.s \
fs/fs_cwd.s \
\
fs/superblock.s \
fs/bitmap.s \
\
fs/ind/ind_add.s \
fs/ind/ind_clr.s \
\
fs/de/de_add.s \
fs/de/de_add_dots.s \
fs/de/de_seek.s \
\
fs/path/path_tok.s \
fs/path/path_build.s \
fs/path/path_read.s \
\
fs/cwd/cwd_init.s \
fs/cwd/cwd_add.s \
fs/cwd/cwd_sub.s \
\
fs/fsp/fsp_init.s \
fs/fsp/fsp_read.s \
fs/fsp/fsp_write.s \
fs/fsp/fsp_blk_to_lba.s

# shell
SRCS_SH = \
sh/arg/arg_data.s \
sh/arg/arg_proc.s \
sh/arg/arg_tok.s \
sh/arg/arg_build.s \
sh/arg/arg_parse.s \
\
sh/exec/exec_cmd.s \
sh/exec/exec_redir.s \
\
sh/hist/history.s \
sh/hist/hist_upd_cl.s \
\
sh/ps/ps_data.s \
sh/ps/ps1_build.s \
\
sh/cmd/cmd_map.s \
\
sh/cmd/sys/cmd_test.s \
sh/cmd/sys/cmd_echo.s \
sh/cmd/sys/cmd_date.s \
sh/cmd/sys/cmd_help.s \
sh/cmd/sys/cmd_clear.s \
\
sh/cmd/file/cmd_cat.s \
sh/cmd/file/cmd_touch.s \
sh/cmd/file/cmd_rm.s \
\
sh/cmd/dir/cmd_pwd.s \
sh/cmd/dir/cmd_ls.s \
sh/cmd/dir/cmd_cd.s \
sh/cmd/dir/cmd_mkdir.s \
sh/cmd/dir/cmd_rmdir.s

# driver
SRCS_DRV = \
drv/ata/ata_data.s \
drv/ata/ata_init.s \
drv/ata/ata_get_sect.s \
drv/ata/ata_read_sect.s \
drv/ata/ata_write_sect.s \
\
drv/disk/disk_data.s \
drv/disk/disk_read_fsp.s \
drv/disk/disk_write_fsp.s \
drv/disk/disk_read_dpi.s \
drv/disk/disk_write_dpi.s \
drv/disk/disk_set_dpi.s \
drv/disk/disk_load_dpi.s \
\
drv/ps2/ps2_chk_sc_set.s \
drv/ps2/ps2_init.s \
drv/ps2/ps2_xlate_off.s \
\
drv/kbd/kbd_data.s \
drv/kbd/kbd_run.s \
drv/kbd/kbd_proc.s \
drv/kbd/kbd_upd_mflg.s \
drv/kbd/kbd_conv_kc.s \
drv/kbd/kbd_hdl_cr.s \
drv/kbd/kbd_hdl_bs.s \
drv/kbd/kbd_hdl_up.s \
drv/kbd/kbd_hdl_down.s \
drv/kbd/kbd_hdl_left.s \
drv/kbd/kbd_hdl_right.s \
\
drv/vga/vga_data.s \
drv/vga/vga_init.s \
drv/vga/vga_putc.s \
drv/vga/vga_puts.s \
drv/vga/vga_putls.s \
drv/vga/vga_clr.s \
drv/vga/vga_clr_line.s \
drv/vga/vga_init_curs.s \
drv/vga/vga_get_curs.s \
drv/vga/vga_set_curs.s \
drv/vga/vga_shu.s \
\
drv/disp/disp_shr_cl.s \
drv/disp/disp_shl_cl.s \
\
drv/rtc/rtc_init.s \
drv/rtc/rtc_get.s \
drv/rtc/rtc_upd_time.s

# interrupt
SRCS_INT = \
int/pic_init.s \
int/ivt_init.s \
\
int/isr_ps2.s \
int/isr_rtc.s \
int/isr_ata.s \

# library
SRCS_LIB = \
lib/file/fparse_lines.s \
\
lib/err/emsg_common.s \
lib/err/emsg_io.s \
lib/err/emsg_syn.s \
\
lib/put/putf.s \
lib/put/puts.s \
lib/put/putns.s \
lib/put/put_utils.s \
\
lib/mem/mem_cmp.s \
lib/mem/mem_cpy.s \
lib/mem/mem_set.s \
lib/mem/mem_size.s \
\
lib/regex/regex_alpha.s \
lib/regex/regex_name.s \
\
lib/conv/ub8_h_to_d.s \
lib/conv/ub8_d_to_c.s

# kernel group
SRCS_GROUP_KERN = \
$(SRCS_KERN) \
$(SRCS_FS) \
$(SRCS_SH) \
$(SRCS_DRV) \
$(SRCS_INT) \
$(SRCS_LIB)

# objects
OBJS_BOOT = $(SRCS_GROUP_BOOT:%.s=./build/%.o)
OBJS_KERN = $(SRCS_GROUP_KERN:%.s=./build/%.o)

# { command
all: $(FAYOS_IMG)

$(FAYOS_IMG): $(BOOT_BIN) $(KERN_BIN) | ./build/
	dd if=/dev/zero of=$(FAYOS_IMG) bs=512 count=$(TOT_SECT_CNT)
	dd if=$(BOOT_BIN) of=$(FAYOS_IMG) bs=512 count=1 conv=notrunc
	dd if=$(KERN_BIN) of=$(FAYOS_IMG) bs=512 seek=16 conv=notrunc

$(BOOT_BIN): $(OBJS_BOOT) | ./build/
	ld -T ./boot/boot.lds -o $@ $^

$(KERN_BIN): $(OBJS_KERN) | ./build/
	ld -T ./kern/kern.lds -o $@ $^

./build/%.o: %.s | ./build/
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
