# Roadmap
## WIP
- remap for fN, 0xE0XX

## TODO PRIORITY

## TODO
- support relative path
- support multi arguments - touch, mkdir, rm, rmdir
- lookup dentry size optimize
- redir append mode, insert mode
- file or dir name: allow ., \_, - (front disallow), disallow /, \, SP, #, all
- calculate low, high address
- replace dap
- support more key (num\_lock, fN, (ins, del, home, end, page up/down))

## Feature
- Tab: autocomplete file or dir
- ls: colorful file or dir, add option
- Time
- Color
- Debug runtime
- Using allocate memory and free - inode, dap, inum, ... `close()`
- Record log, error log
- OBF, IBF timeout error

## Command
- cp
- mv
- printf
- read
- grep
- find
- poweroff

## Function
- `fopen()` - file open, append, create
- `fclose()` - file close
- `opendir()` - dir open 
- `closedir()` - dir close
