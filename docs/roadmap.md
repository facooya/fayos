## Handle error  
no dir (rmdir)  
no file, not file (cat, rm)  

## Feature history  
up down - raw history

## Feature tab  
tab autocomplete file or dir

## Feature pwd  
PWD: Print Working Directory  
fayos:[PWD]#  

## Feature ls  
colorful file dir

## Feature file cache  
file_cache file match return lba  

## Kernel  
kernel time, color  

## File or dir name  
allow ., _, - (front disallow)  
disallow /, \, SP, all  

## include define .equ  
.equ include/...  

## Logics  
read_arg(argv_offset)  
cmp_name(src, dst): ret: file_lba_cache = lba, ax = 0: success, 1: no match  

- Seperate split function
- Seperate exec redir logic