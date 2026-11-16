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
  k dq 0

section '.text' executable

_start:
  pop rcx
  cmp rcx, 5
  jl exit

  mov rdi, [rsp+8]
  movzx r12d, byte [rdi]
  sub r12, '0'

  mov rdi, [rsp+16]
  movzx rax, byte [rdi]
  sub rax, '0'
  mov [k], rax

  call input
  call read_write
  jmp exit

input:
   mov rdi, [rsp+32]
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

   mov rdi, [rsp+40]
   mov rax, 2
   mov rsi, 0x241
   mov rdx, 0644
   syscall
   test rax, rax
   js exit
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
   mov r14, rax
   mov r13, rax

   cmp r12, 1
   je .loop_2
   jmp .loop_3

.loop_2:
   mov rbx, [k]
.loop_2_iter:
   dec r13
   js .done
   add [buffer + r13], bl
   jmp .loop_2_iter

.loop_3:
   mov rbx, [k]
.loop_3_iter:
   dec r13
   js .done
   sub [buffer + r13], bl
   jmp .loop_3_iter

.done:
   mov rax, 1
   mov rdi, r9
   mov rsi, buffer
   mov rdx, r14
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