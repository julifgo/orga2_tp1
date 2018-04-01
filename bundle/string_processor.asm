; FUNCIONES de C
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf
; FUNCIONES DE STRING_PROCESSOR DE C
	extern str_len
	extern str_copy

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
; Definicion Size and offsets de key
	%define struct_key_size 12 ;puntero nombre 8, length es uint32 (doubleword unsigned int) 4
	%define struct_key_offset_length 0
	%define struct_key_offset_value 4


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

	;TODO. RESOLVER DUDA 2
	mov [rax + struct_node_offset_next], rdx
	mov [rax + struct_node_offset_previous], rdx
	mov [rax + struct_node_offset_f], rdi ;en rdi tengo la direccion de memoria de f
	mov [rax + struct_node_offset_g], rsi ;en rsi tengo la direccion de memoria de g
	mov [rax + struct_node_offset_type], rdx ;en rdx tengo el valor del enum type

	pop rbp
	ret

global string_proc_key_create
string_proc_key_create:
	push rbp
	mov rbp, rsp
	push r12
	push r13

	call str_len ;uso la funcion auxiliar de c de longitud con el value que ya esta en rdi
	mov r13, rax ;muevo el length del value
	;es importante moverlo a un registro que deba preservar valor, sino str_copy o malloc podria pisarlo (por ejemplo si se usa rdx e vez de r13)

	call str_copy
	mov r12, rax

	push rdi ;resguardo el parametro (aunque ya no lo necesito usar mas)
	mov rdi, struct_key_size
	call malloc
	pop rdi

	mov [rax + struct_key_offset_length], r13
	mov [rax + struct_key_offset_value], r12

	pop r13
	pop r12
	pop rbp
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
	push rbp
	mov rbp, rsp

	push rdi ;resguardo el puntero a key, puesto que en rdi debo poner el value para liberarlo

	mov rdx, [rdi + struct_key_offset_value] ;leo el puntero a value
	mov rdi, rdx
	call free ;libero value

	pop rdi

	mov rdx, 0
	mov [rdi + struct_key_offset_length], rdx
	mov rdx, NULL
	mov [rdi + struct_key_offset_value], rdx

	call free


	pop rbp
	ret

global string_proc_list_add_node
string_proc_list_add_node:
	ret

global string_proc_list_apply
string_proc_list_apply:
	ret
