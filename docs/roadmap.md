Feature
fix right arrow - max_cur_pos_x
fix backspace left shift
up down - raw history

Seperate fayfs.s
dentry.s
metadata.s
super.s
fs/fayfs/README.md

Feature
directory

Handle error
no dir
no file
same file name
same dir name

Feature
PWD: Print Working Directory
fayos:[PWD]#

cmd kernel time, color, mkdir, rmdir

cli_buf
buf [A-Za-z0-9], ignore space, . / > >> <
E.g., ignore space, SP: space
O: cmd
O: SPcmd
O: SPSPSP...cmd
O: SPSPcmdSPSPoptSPSPSParg

Ignore prompt space, null

redirection (>, >>)
cat arg > file
cmd arg redir redir_target

Feature
tab autocomplete file or dir
