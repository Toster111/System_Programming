format elf64
public _start

include 'func.asm'

section '.' writable

pathname db "my", 0
place rb 5

_start:
   mov rax, 2
   mov rdi, pathname
   mov rsi, 1101o
   mov rdx, 777o
   syscall
   mov rsi, place
   call number_str
   call print_str
   call new_line
   call exit, 0
place rb 5

_start:
   mov rax, 2
   mov rdi, pathname
   mov rsi, 1101o
   mov rdx, 777o
   syscall
   mov rsi, place
   call number_str
   call print_str
   call new_line
   call exit
