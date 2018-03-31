; FUNCIONES de C
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf

; /** defines bool y puntero **/
	%define NULL 0
	%define TRUE 1
	%define FALSE 0

;  Definicion Size and offsets de lista
	%define struct_lista_size 24 ; tamaño del struct lista: 8b pointer a char, 8b first, 8b last
	%define struct_lista_offset_nombre 0
	%define struct_lista_offset_first 8
	%define struct_lista_offset_last 16


section .data


section .text

global string_proc_list_create
string_proc_list_create:
	push rbp
	mov rbp, rsp
	push rdi ;preservo el parametro pasado al metodo
	;chequear si en rdi viene algo asignado.
	mov rdi, struct_lista_size ;pido memoria para almacenar la estructura de una lista
	call malloc

	pop rdi ;recupero el parametro
	mov rdx, NULL ;rdx no debe ser preservado
	mov [rax + struct_lista_offset_nombre], rdi
	mov [rax + struct_lista_offset_first], rdx
	mov [rax + struct_lista_offset_last], rdx

	pop rbp
	ret

global string_proc_node_create
string_proc_node_create:
	ret

global string_proc_key_create
string_proc_key_create:
	ret

global string_proc_list_destroy
string_proc_list_destroy:
	push rbp
	mov rbp, rsp
	;TODO. DEBEMOS LIBERAR NODOS.

	call free

	pop rbp
	ret

global string_proc_node_destroy
string_proc_node_destroy:
	ret

global string_proc_key_destroy
string_proc_key_destroy:
	ret

global string_proc_list_add_node
string_proc_list_add_node:
	ret

global string_proc_list_apply
string_proc_list_apply:
	ret
