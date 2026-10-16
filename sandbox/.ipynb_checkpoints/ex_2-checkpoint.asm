format ELF64
public _start
public input
public convert_ascii_int
public convert_int_ascii
public print_msg
public ex_1
public _exit

section '.data' writable
	msg_1 db "Enter n:", 0xA, 0
	l_msg_1 = $ - msg_1

	msg_2 db "ERROR 2", 0xA, 0
	l_msg_2 = $ - msg_2

section '.bss' writable
	buffer rd 256 ; Для хранения ввода
	buffer_2 rd 256 ; Для хранения вывода
	accumulat rq 1

section '.text' executable
_start:
	mov rsi, msg_1
	mov rdx, l_msg_1
	call  print_msg

	call input

	call convert_ascii_int

	call ex_1	

	call convert_int_ascii


	mov rsi, buffer_2
	add rsi, rdx
	mov rax, 256
	sub rax, rdx
	mov rdx, rax
	call print_msg 

	call _exit

input: ;Метка для ввода
	xor rax, rax
	mov rdi, 0
	mov rsi, buffer ; Буфер для записи с клавиатуры
	mov rdx, 256

	syscall ; Системный вызов в виде прерывания


	xor rbx, rbx
	xor rdx, rdx
	.iter_n:
			cmp byte [rsi + rbx], 0xA
			je .next_n
			inc rbx
			jmp .iter_n

	.next_n:
			mov [rsi + rbx], rdx

	ret

convert_ascii_int: ; Перевод из ascii нотации в int. В rsi хранится адрес, rdx - длина.
	; rax - аккумулятор числа
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
			inc rsi ; Следующая цифра

			jmp .iter

	.next:
			mov [accumulat], rax

			ret

convert_int_ascii:
	mov rax, [accumulat]
	mov rdx, rax
	mov rsi, buffer_2

	mov rbx, 255
	mov rcx, 10

	.iter_2:
			cmp rax, 0
			je .next_2

			xor rdx, rdx
			div rcx
			add dl, '0'
			mov [rsi + rbx], dl
			dec rbx

			jmp .iter_2

	.next_2:
			ret

ex_1:
	mov rax, [accumulat]
	push rax
	xor rdx, rdx
	mov [accumulat], rdx
	mov rcx, 2

	div rcx 

	cmp rdx, 0
	je .error
		
	pop rax ; rax = n
	mul rcx ; rax = 2n
	xor rdx, rdx
	inc rax
	
	.iter:
		cmp rax, 1
		je .next
		add [accumulat], rax
		sub rax, 2
		jmp .iter

	.next:
		add [accumulat], rax
		ret

	.error:
		pop rax
		mov rsi, msg_2
        	mov rdx, l_msg_2
	
		call print_msg	
	
		ret

print_msg: ; Вызов вывода в командную строку
	mov rax, 1
	mov rdi, 1
	
	syscall

	ret

section '.exit' executable
_exit:
	mov rax, 60
	mov rdi, 0
	
	syscall
