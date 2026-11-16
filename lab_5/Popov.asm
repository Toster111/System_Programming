format ELF64

public _start
public input
public read_write
public buffer
public exit

section '.bss' writable
  buffer rb 1024

section '.data' writable
  file_size dq 0
  newline   db 10

section '.text' executable

_start:
  pop rcx
  cmp rcx, 3
  jl exit

  call input
  call read_write
  jmp exit

input:
   mov rdi, [rsp+16]
   mov rax, 2
   mov rsi, 0
   syscall
   cmp rax, 0
   jl exit
   mov r8, rax

   mov rax, 8
   mov rdi, r8
   mov rsi, 0
   mov rdx, 2
   syscall
   mov [file_size], rax

   mov rdi, [rsp+24]
   mov rax, 2
   mov rsi, 0x241
   mov rdx, 644
   syscall
   jl exit
   mov r9, rax

   ret

read_write:
.loop:
   cmp qword [file_size], 1024
   jb .last_chunk

   sub qword [file_size], 1024

   mov rax, 8
   mov rdi, r8
   mov rsi, [file_size]
   mov rdx, 0
   syscall

   mov rax, 0
   mov rdi, r8
   mov rsi, buffer
   mov rdx, 1024
   syscall

   test rax, rax
   jle .cont

   jmp .process

.last_chunk:
   mov rdx, [file_size]
   test rdx, rdx
   jz .cont

   mov rax, 8
   mov rdi, r8
   mov rsi, 0
   mov rdx, 0
   syscall

   mov rax, 0
   mov rdi, r8
   mov rsi, buffer
   mov rdx, [file_size]
   syscall

   test rax, rax
   jle .cont

   mov qword [file_size], 0

.process:
   mov r12, rax
   lea r13, [rax - 1]

.loop_2:
   test r13, r13
   js .done

   mov bl, byte [buffer + r13]
   cmp bl, 10
   je .carr

   dec r13
   jmp .loop_2

.carr:
   mov rdx, r12
   sub rdx, r13
   dec rdx
   test rdx, rdx
   jz .skip_carr

   lea rsi, [buffer + r13 + 1]
   mov rax, 1
   mov rdi, r9
   syscall

   mov rax, 1
   mov rdi, r9
   lea rsi, [newline]
   mov rdx, 1
   syscall

.skip_carr:
   mov r12, r13
   dec r13
   jmp .loop_2

.done:
   test r12, r12
   jz .loop

   mov rdx, r12
   mov rsi, buffer
   mov rax, 1
   mov rdi, r9
   syscall

   mov rax, 1
   mov rdi, r9
   lea rsi, [newline]
   mov rdx, 1
   syscall

   jmp .loop

.cont:
   mov rax, 3
   mov rdi, r8
   syscall

   mov rax, 3
   mov rdi, r9
   syscall

   ret

exit:
   mov rax, 60
   xor rdi, rdi
   syscall