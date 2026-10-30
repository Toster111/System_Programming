format ELF64
public _start

;public input

public _exit

section '.bss' writable

	file_name_first rb 256
	file_name_second rb 256

section '.text' writable
_start:
	pop rcx
	cmp rcx, 2
	jne _exit

	mov rax, 1
	mov rdi, 1
	mov rsi, [rsp + 8]
	mov rdx, 256
	
	syscall

	jmp _exit
	
section '.exit' executable
_exit:
	mov rax, 60
	mov rdi, 0

	syscall
