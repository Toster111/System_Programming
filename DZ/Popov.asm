format elf64
public _start
public compare_command
include 'func.asm'

section '.bss' writable
	buffer_begin rq 1
	buffer_end rq 1
	len_array rq 1
	
	buffer_input rb 100
	
	number rq 1
    place rb 100

section '.data' writable
	f  db "/dev/urandom",0
	
	msg_error db 'ERROR',0xa,0
	
	msg_command db 'command: ', 0
	msg_cell db 'cell: ', 0
	msg_value db 'value: ', 0
	msg_result db 'count: ', 0
	msg_done db 'done', 0xa, 0
	
	msg_change db 'change', 0
	msg_print db 'print', 0
	msg_random db 'random', 0
	msg_prime db 'prime', 0
	msg_even db 'even', 0
	msg_reverse db 'reverse', 0
	msg_q db 'q!', 0

	section '.text' executable
	
_start:
	;; Считываем количество параметров командной строки
	pop rcx
	cmp rcx, 2
	jne error

	;; Преобразуем значение из командной строки в число (количество ячеек)
	mov rsi, [rsp+8]
	call str_number
	mov r8, rax          ; r8 = N (количество элементов)
	mov [len_array], r8  ; сохраняем количество элементов

	;; Вычисляем размер в байтах (N * 8)
	mov r9, r8
	shl r9, 3            ; r9 = N * 8

	;; Получаем начальное значение адреса кучи
	xor rdi, rdi
	mov rax, 12
	syscall
	cmp rax, 0
	jl error
	mov [buffer_begin], rax

	;; Увеличиваем размер кучи на N * 8 байт
	mov rdi, [buffer_begin]
	add rdi, r9
	mov rax, 12
	syscall
	cmp rax, 0
	jl error
	mov [buffer_end], rax

	call compare_command
	call exit
	
;; Функция сравнения строки переданной
compare_command:
	mov rsi, msg_command
	call print_str
	
	mov rsi, buffer_input
	call input_keyboard
	
	mov r13, rsi
	mov r14, msg_change
	call equal
	test rax, rax
	jz change
	
	mov r13, rsi
	mov r14, msg_print
	call equal
	test rax, rax
	jz print
	
	mov r13, rsi
	mov r14, msg_random
	call equal
	test rax, rax
	jz random

	mov r13, rsi
	mov r14, msg_prime
	call equal
	test rax, rax
	jz count_prime

	mov r13, rsi
	mov r14, msg_even
	call equal
	test rax, rax
	jz count_even

	mov r13, rsi
	mov r14, msg_reverse
	call equal
	test rax, rax
	jz reverse

	mov r13, rsi
	mov r14, msg_q
	call equal
	test rax, rax
	jz exit
	
	call new_line
	jmp compare_command

change:
	mov rsi, msg_cell
	call print_str
	
	mov rsi, buffer_input
	call input_keyboard
	call str_number
	
	cmp rax, [len_array]
	jge error
	
	mov r9, rax
	shl r9, 3            ; смещение = индекс * 8
	mov r10, [buffer_begin]
	add r10, r9          ; r10 = адрес нужной ячейки
	
	mov rsi, msg_value
	call print_str
	
	mov rsi, buffer_input
	call input_keyboard
	call str_number
	
	mov [r10], rax       ; записываем 8 байт в кучу
	
	jmp compare_command

print:
	mov rsi, msg_cell
	call print_str
	
	mov rsi, buffer_input
	call input_keyboard
	call str_number
	
	cmp rax, [len_array]
	jge error
	
	mov r9, rax
	shl r9, 3
	mov r10, [buffer_begin]
	add r10, r9
	
	mov rax, [r10]       ; читаем 8 байт из кучи
	mov rsi, buffer_input
	call number_str
	call print_str
	call new_line
	
	jmp compare_command

random:
	mov rdi, f
	mov rax, 2 
	mov rsi, 0
	syscall 
	cmp rax, 0 
	jl error 
	mov r8, rax          ; r8 = файловый дескриптор

	xor r12, r12         ; r12 = индекс (счётчик цикла)
.loop_1:
	cmp r12, [len_array]
	jge .done
	
	; Читаем 8 случайных байт
	mov rax, 0
	mov rdi, r8
	mov rsi, number
	mov rdx, 8
	syscall
	
	; Записываем в кучу
	mov rax, [number]
	mov r9, r12
	shl r9, 3
	mov r10, [buffer_begin]
	add r10, r9
	mov [r10], rax
	
	; Выводим значение
	mov rax, [number]
	mov rsi, place
	call number_str
	call print_str
	call new_line
	
	inc r12
	jmp .loop_1

.done:
	mov rax, 3
	mov rdi, r8
	syscall

	jmp compare_command

;; --- ПОДСЧЕТ ПРОСТЫХ ЧИСЕЛ ---
count_prime:
	xor r12, r12         ; r12 = индекс
	xor r15, r15         ; r15 = счетчик простых чисел
	
.loop_prime:
	cmp r12, [len_array]
	jge .done_prime
	
	mov r9, r12
	shl r9, 3
	mov r10, [buffer_begin]
	add r10, r9
	mov rax, [r10]       ; загружаем число
	
	call is_prime        ; проверяем на простоту
	test rax, rax
	jz .next_prime
	inc r15              ; если простое, увеличиваем счетчик

.next_prime:
	inc r12
	jmp .loop_prime
	
.done_prime:
	mov rsi, msg_result
	call print_str
	
	mov rax, r15
	mov rsi, place
	call number_str
	call print_str
	call new_line
	
	jmp compare_command

;; Вспомогательная функция проверки на простое число
;; Вход: rax - число, Выход: rax = 1 если простое, 0 если нет
is_prime:
	push rbx
	push rcx
	push rdx
	push r8
	
	mov r8, rax          ; r8 = исходное число
	
	cmp rax, 2
	jb .not_prime        ; 0 и 1 не простые
	je .is_prime         ; 2 - простое
	
	test rax, 1
	jz .not_prime        ; четные числа > 2 не простые
	
	mov rbx, 3           ; начинаем проверку с 3
	
.check_loop:
	mov rcx, rbx
	imul rcx, rbx        ; rcx = rbx^2
	cmp rcx, r8
	ja .is_prime         ; если rbx^2 > N, то число простое
	
	mov rax, r8
	xor rdx, rdx
	div rbx              ; делим N на rbx
	test rdx, rdx
	jz .not_prime        ; если делится без остатка - не простое
	
	add rbx, 2           ; проверяем только нечетные делители
	jmp .check_loop
	
.is_prime:
	mov rax, 1
	jmp .ret_prime
.not_prime:
	xor rax, rax
.ret_prime:
	pop r8
	pop rdx
	pop rcx
	pop rbx
	ret


;; --- ПОДСЧЕТ ЧЕТНЫХ ЧИСЕЛ ---
count_even:
	xor r12, r12         ; r12 = индекс
	xor r15, r15         ; r15 = счетчик четных
	
.loop_even:
	cmp r12, [len_array]
	jge .done_even
	
	mov r9, r12
	shl r9, 3
	mov r10, [buffer_begin]
	add r10, r9
	mov rax, [r10]
	
	test rax, 1          ; проверяем младший бит
	jnz .next_even       ; если бит 1, число нечетное
	inc r15              ; иначе четное
	
.next_even:
	inc r12
	jmp .loop_even
	
.done_even:
	mov rsi, msg_result
	call print_str
	
	mov rax, r15
	mov rsi, place
	call number_str
	call print_str
	call new_line
	
	jmp compare_command


;; --- РЕВЕРСИРОВАНИЕ МАССИВА ---
reverse:
	xor r12, r12         ; r12 = левый индекс (0)
	mov r13, [len_array]
	dec r13              ; r13 = правый индекс (len - 1)
	
.loop_rev:
	cmp r12, r13
	jge .done_rev        ; пока левый < правого
	
	; Адрес левого элемента
	mov r9, r12
	shl r9, 3
	mov r10, [buffer_begin]
	add r10, r9
	mov rax, [r10]       ; rax = левый элемент
	
	; Адрес правого элемента
	mov r9, r13
	shl r9, 3
	mov r11, [buffer_begin]
	add r11, r9
	mov rbx, [r11]       ; rbx = правый элемент
	
	; Меняем местами
	mov [r10], rbx
	mov [r11], rax
	
	inc r12
	dec r13
	jmp .loop_rev
	
.done_rev:
	mov rsi, msg_done
	call print_str
	jmp compare_command

error:
	mov rsi, msg_error
	call print_str
	call exit