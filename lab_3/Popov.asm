format ELF64

public _start
public input
public first
public second
public handler
public str_to_int
public finally

section '.data' writable
	error_0 db "ERROR 0. Zero arguments", 0xA
	l_error_0 = $-error_0

section '.bss' writable
	buffer rb 4
	buffer_2 rq 3

section '.text' executable

_start:
	pop rcx
	jmp input

input:
        xor rax, rax
        xor rbx, rbx
	xor rdx, rdx
        inc rax
	cmp rax, rcx
	je .error_0

	mov rsi, [rsp + 8]
	mov dl, [rsi]

	jmp handler

.error_0:
                mov rdx, l_error_0
                mov rsi, error_0
                mov rax, 1
                mov rdi, 1

                syscall

                jmp exit

handler:
        cmp dl, '1'
        je first
	cmp dl, '2'
	je second
	jmp exit

second:
	xor rcx, rcx
	.iter:
		mov rsi, [rsp + 16 + 8*rcx]
		call str_to_int
		inc rcx
		cmp rcx, 3
		jne .iter

	mov rbx, [buffer_2 + 8]
	mov rcx, [buffer_2 + 16]

	mov rax, [buffer_2 + 8]
	xor rdx, rdx
	div rcx
	mul rbx
	add rax, rbx

	mov [buffer + 3], 0xA


	xor rdx, rdx
	mov rcx, 2
	mov rbx, 10

	.iter1:
		xor rdx, rdx
		cmp rax, 0
		je .next
		div rbx
		add dl, '0'
		mov [buffer + rcx] , dl
		dec rcx
		jne .iter1
	.next:
		mov rcx, 3
		call finally

		jmp exit


str_to_int:
	push rcx
	xor rax, rax
	.iter:
		cmp byte [rsi], 0
		je .next
		mov dl, byte [rsi]
		sub dl, '0'
		push rdx
		mov rdx, 10
		mul rdx
		pop rdx
		add rax, rdx
		inc rsi

		jmp .iter

	.next:
		mov [buffer_2 + 8 * rcx], rax
		pop rcx
		ret

first:
	mov [buffer + 3], 0xA
	mov rsi, [rsp + 16]
	mov [buffer + 2], 0xA
	push rax
	push rbx
	push rcx
	push rdx
	push rsi

	xor rax, rax
	mov rbx, 2
	mov al, [rsi]
	mov rcx, 10
	.iter1:
		xor rdx, rdx
		div rcx
      		add dl, '0'
		mov [buffer+rbx], dl
		dec rbx
      		cmp rax, 0
		jne .iter1


	mov rcx, 4
	call finally

	pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax

	jmp exit

finally:
	mov rdx, rcx
	mov rsi, buffer
	mov rax, 1
	mov rdi, 1
	syscall

	ret

section '.exit' executable
exit:
    mov rax, 60
    xor rdi, rdi
    syscall
