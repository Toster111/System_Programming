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

	call convert_int_ascii ; вызов подпрограммы для преобразования из числа в ascii

        mov rsi, buffer_2
        mov rdx, 256

        call print_msg

	call _exit

input: ;Метка для ввода
	xor rax, rax
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
	mov rcx, 45
	cmp [rsi], rcx
	je .negat
	push 0

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
			pop rbx
			cmp rbx, 1
			je .next_neg
			mov [accumulat], rax

			ret

	.negat:
			push 1
			inc rsi

			jmp .iter
	.next_neg:
			not rax
			inc rax
			mov [accumulat], rax

			ret

convert_int_ascii:
	mov rax, [accumulat]
	mov rdx, rax
	mov rsi, buffer_2

	shr rdx, 63 ; Сдвиг регистра, чтобы узнать значащий бит

	push rdx

	mov rbx, 255
	mov rcx, 10

	cmp rdx, 1
	je .negat_2

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
			pop rcx
			cmp rcx, 1
			je .add_neg

			ret

	.negat_2:
			not rax
			inc rax

			jmp .iter_2

	.add_neg:
			mov rcx, 45
			mov [rsi + rbx], cl

			ret

ex_1:
	mov rax, 1
	xor rbx, rbx
	.iter_1:

		; (-1)^k (k(k+1)(3k+1)(3k+2))
		xor rdx, rdx
		mov rcx, rax ; rcx = k
		mov rdx, 3 
		mul rdx	; rax = 3k, rdx = 0 (при мал числах)
		inc rax ; rax = 3k + 1
		push rax ; 3k + 1
		inc rax ; (3k + 2)
		pop rdx ; rdx = 3k + 1 
		mul rdx ; (3k + 2)(3k + 1), rdx = 0
		mul rcx ; rax = k(3k + 2)(3k + 1)
		inc rcx ; rcx = k + 1
		mul rcx ; rax = k(k + 1)(3k + 2)(3k + 1)
		push rax ; k(k + 1)(3k + 2)(3k + 1)
		dec rcx ; k
		mov rax, rcx
		push rcx
		mov rcx, 2
		xor rdx, rdx
		div rcx
		pop rcx
		pop rax

		cmp rdx, 1 ;проверка на чётность k
		jne .itn
		not rax ; инвертируем
		inc rax ; доп код
		
		.itn:
		
		add rbx, rax

		mov rax, rcx ; rax = k
		
		cmp rax, [accumulat]
                je .next_1
		
		inc rax

		jmp .iter_1
	.next_1:
		mov [accumulat], rbx

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
