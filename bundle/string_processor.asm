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
; Definicion Size and offsets de node
	%define struct_node_size 40 ;punteros next y prev: 8, direcciones memoria func: 8, enum: 8
	%define struct_node_offset_next 0
	%define struct_node_offset_previous 8
	%define struct_node_offset_f 16
	%define struct_node_offset_g 24
	%define struct_node_offset_type 32


section .data


section .text

global string_proc_list_create
string_proc_list_create:
	push rbp
	mov rbp, rsp
	push rdi ;preservo el parametro pasado al metodo
	
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
	push rbp
	mov rbp, rsp
	push rdi

	mov rdi, struct_node_size ;pido memoria para almacenar la estructura de un nodo
	call malloc	

	pop rdi ;recupero el parametro
	mov rdx, NULL ;rdx no debe ser preservado

	mov [rax + struct_node_offset_next], rdx
	mov [rax + struct_node_offset_previous], rdx
	mov [rax + struct_node_offset_f], rdi ;en rdi tengo la direccion de memoria de f
	mov [rax + struct_node_offset_g], rsi ;en rsi tengo la direccion de memoria de g
	mov [rax + struct_node_offset_type], rdx ;en rdx tengo el valor del enum type

	pop rbp
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
	push rbp
	mov rbp, rsp
	
	mov rdx, NULL

	;en rdi tengo el puntero al nodo
	mov [rdi + struct_node_offset_next], rdx
	mov [rdi + struct_node_offset_previous], rdx
	mov [rdi + struct_node_offset_f], rdx
	mov [rdi + struct_node_offset_g], rdx

	call free


	pop rbp
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
