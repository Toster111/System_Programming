; rax = 4
; rbx = 1
; rcx - сюда записываем адрес ячейки, хранящей начало выводимой строки
; rdx - кол-во вводимых символов строки
; int 0x80 & rdx = 1 & rbx = 0 - корректное завершение работы
; 0xA - создание коретки 

format ELF64
public _start
msg db "Попов", 0xA, "Тимофей", 0xA, "Дмитриевич", 0xA, 0

_start:
    mov rax, 4
    mov rbx, 1
    mov rcx, msg
    mov rdx, 48
    int 0x80
    mov rax, 1
    mov rbx, 0
    int 0x80
