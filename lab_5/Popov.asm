format ELF64
public _start

public open
public read_write
public _exit

section '.data' executable
	file_name_1 db "example.txt"
        file_name_l_1 = $-file_name_1

	file_name_2 db "example_2.txt"
        file_name_l_2 = $-file_name_2	

section '.bss' writable 

	buffer_file_first rb 256

section '.text' writable
_start:
	pop rcx
	cmp rcx, 3
	jne _exit
	
	call open
	
	call read_write 
	
	syscall

	jmp _exit

open:

	mov rax, 2 ; тут харнится fd после syscall
	mov rdi, file_name_1
	xor rsi, rsi ; 0 - флаг только на чтение 

	cmp rax, 0 ;если вернулось отрицательное значение,
   	jl _exit
	
	syscall

	mov r8, rax ; хранение fd первого файла
	
	mov rax, 2
	mov rdi, file_name_2
	mov rsi, 1 ; 1 - флаг только на запись
	
	cmp rax, 0 ;если вернулось отрицательное значение,
        jl _exit

	syscall

	mov r10, rax ; хранение fd второго файла

	ret

read_write:
	xor rax, rax
	mov rdi, r8
	mov rsi, buffer_file_first
	mov rdx, 256

	syscall

	mov rax, 1
	mov rdi, r10
	mov rsi, buffer_file_first
	mov rdx, 256

	syscall

	ret
	
section '.exit' executable
_exit:
	mov rax, 60
	mov rdi, 0

	syscall
