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
	buffer rb 256
	accumulat rq 1

section '.text' executable
_start:
	mov rsi, msg_1
	mov rdx, l_msg_1
	call  print_msg

	call input

	call _exit

input: ;Метка для ввода
	xor rax, rax
	mov rsi, buffer ; Буфер для записи с клавиатуры
	mov rdx, 256

	syscall ; Системный вызов в виде прерывания

	ret

convert_ascii_int: ; Перевод из ascii нотации в int. В rsi хранится адрес, rdx - длина.
	; rax - аккумулятор числа
	xor rax, rax
	if [rsi] eq 45
	push 1
	inc [rsi]
	else
	push 0
	end if
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
		if rbx eq 1
		not rax
		inc rax
		end if
		mov [accumulat], rax

		ret
		
convert_int_ascii:
	

ex_1:
	mov rax, 1
	.iter_1:
		cmp rax, [accumulat]
		je .next_1

		; (-1)^k (k(k+1)(3k+1)(3k+2))
		xor rdx, rdx
		mov rcx, rax ; rcx = k
		mov rdx, 3 
		mul rdx	; rax = 3k
		inc rax ; rax = 3k + 1
		push rax ; 3k + 1
		inc rax ; (3k + 2)
		pop rdx ; rdx = 3k + 1 
		mul rdx (3k + 2)(3k + 1)
		mul rcx ; rax = k(3k + 2)(3k + 1)
		inc rcx ; rcx = k + 1
		mul rcx ; rax = k(k + 1)(3k + 2)(3k + 1)
		push rax ; k(k + 1)(3k + 2)(3k + 1)
		dec rcx ; k
		mov rax, rcx
		mov rcx, 2
		div rcx
		pop rax
		if rdx eq 1 проверка на чётность k
		not rax ; инвертируем
		inc rax ; доп код
		end if
		
		add rbx, rax

		mov rax, rcx ; rax = k
		inc rax
		jmp .iter_1
	.next_1:
		; напишу позже программу для преобразования из числа в ascii
		
		
		
print_msg: ; Вызов вывода в командную строку
	mov rax, 1
	mov rbx, 1
	
	syscall

	ret

section '.exit' executable
_exit:
	mov rax, 60
	mov rdi, 0
	
	syscall
