# Roadmap
## WIP
- root argument - ls
- root protect - mkdir, rmdir, touch, rm, cat

## Feature
- Tab: autocomplete file or dir
- ls: colorful file or dir, add option
- Time
- Color
- Debug runtime
- Comment
- Using allocate memory and free - inode, dap, inum, ...

## Command
- cp
- mv
- printf
- read
- grep
- find

## Function
- read\_block(\*dap, \*inode, \*inum) \<ret\> dx:ax = seg:off, cx = return code

## TODO
- support relative path
- support multi arguments - touch, mkdir, rm, rmdir
- add require argument error
- lookup dentry size optimize
- redir append mode, insert mode
- file or dir name: allow ., \_, - (front disallow), disallow /, \, SP, #, all
- calculate low, high address

## Library
- file open?/append/create
