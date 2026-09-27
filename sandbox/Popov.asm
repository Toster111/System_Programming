format ELF64 executable 3

; Убрал public для облегчения

entry _start

segment readable writeable 
	msg db "AMVtdiYVETHnNhuYwnWDVBqL"
	msg_len = $-msg

	intg dq 5277616985

segment readable executable
	buffer db 256 dup (?)
	buffer_2 db 64 dup (?)
	n dq 0
	m dq 0
	k dq 0
	sym db 0
	incr dq 0
	count_n dq 0

	summ dq 0

segment readable executable
first:
	push rcx
	push rbx
	push rax
	push rdx
	xor rcx, rcx
	mov rbx, msg_len
	dec rbx
	.iter:
		mov al, [msg + rbx]
		dec rbx
		mov [buffer + rcx], al
		inc rcx
		cmp rcx, msg_len
		jne .iter
	mov [buffer + msg_len], 0xA
	mov rdx, msg_len + 1
	mov rax, 1
        mov rbx, 1
        mov rcx, buffer
        syscall
	pop rdx
	pop rax
	pop rbx
	pop rcx
	ret

second:
	push rax
	push rdx
	push rcx
	push rbx
	xor rdx, rdx
	xor rcx, rcx
	mov rax, [n]
	add rax, [k]
	mov rbx, [m]
	mov [count_n], rbx
	mov bh, [sym]
	.iter:
		cmp rdx, rax
		je .finally
		cmp rcx, [count_n]
		je .append_carr
		mov byte [buffer + rdx], bh
		inc rdx
		inc rcx
		jmp .iter
		
	.finally:
		mov rax, 1
		mov rbx, 1
		mov rcx, buffer
		syscall
		pop rbx
		pop rcx
		pop rdx
		pop rax
		ret
		
.append_carr:
	mov byte [buffer+rdx], 0xA
	inc rdx
	xor rcx, rcx
	push rbx
	mov rbx, [incr]
	add [count_n], rbx
	pop rbx
	jmp .iter

third:
	; div, где rax - целое число и число после деления, rdx - остаток
	push rax
	push rbx
	push rcx
	push rdx
	xor rbx, rbx
	mov rax, [intg]
	mov rcx, 10
	.iter1:
		xor rdx, rdx
		div rcx
		add rbx, rdx
		cmp rax, 0
		jne .iter1
	mov rax, rbx
	xor rbx, rbx
	.iter2:
		xor rdx, rdx
		div rcx
		add rdx, '0'
		mov [buffer + rbx], dl
		inc rbx
		cmp rax, 0
		jne .iter2
	mov rdx, rbx
	xor rax, rax
	xor rcx, rcx
        dec rbx
        .reverse:
                mov al, [buffer + rbx]
                dec rbx
                mov [buffer_2 + rcx], al
                inc rcx
                cmp rcx, rdx 
                jne .reverse
        mov [buffer_2 + rdx], 0xA
        inc rdx
			
	.finally_1:
		mov rax, 1
		mov rbx, 1
		mov rcx, buffer_2
		syscall
		pop rdx
		pop rcx
		pop rbx
		pop rax
		ret

_start:
	call first
	mov [n], 66
	mov [m], 6
	mov [k], 11
	mov [sym], '+'
	call second
	mov [n], 21
	mov [m], 1
	mov [k], 6
	mov [sym], '8'
	mov [incr], 1
	call second
	call third
	call exit

segment readable executable
exit:
        mov rax, 60
        xor rdi, rdi
        syscall   
