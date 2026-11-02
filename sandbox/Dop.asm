format ELF64 executable 3

entry _start

segment readable executable
	msg db "MVtdiYVETHnNhuYwnWDVBqL"
	msg_l = $-msg

segment readable writable
	intg dq 0
	len dq 0

segment readable executable

input:
	xor rax, rax
	xor rdi, rdi
	mov rsi, intg
	mov rdx, 1

	syscall
	
	sub [intg], '0'

	ret

_start:
	call input

	
	
	.iter:
		mov rax, [len]
		mov rsi, msg		
		add rsi, rax		

		mov rax, 1
		mov rdi, 1
		mov rdx, [intg] ;Длина
	
		syscall

		mov rsi, "0xA"
		mov rdx, 1
		
		syscall

		mov rax, [intg]
		add [len], rax			
		
		mov rax, [len]

		cmp rax, [msg_l]
		jb .iter
		
	.ost:
		mov rbx, [len]
		sub rbx, [msg_l]

		cmp rbx, 0
		je .finally

		mov rax, len
		add rax, rbx
		add rax, msg
               	mov rcx, rax

                mov rax, 1
                mov rbx, 1
                mov rdx, rbx ;Длина

               syscall

	.finally:
		call exit


segment readable executable
exit:
        mov rax, 60
        xor rdi, rdi
        syscall	 
