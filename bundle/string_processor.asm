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
	push r12
	push rdi ;preservo el parametro pasado al metodo
	
	call str_copy
	mov r12, rax

	mov rdi, struct_lista_size ;pido memoria para almacenar la estructura de una lista
	call malloc

	pop rdi ;recupero el parametro
	mov rdx, NULL ;rdx no debe ser preservado

	mov [rax + struct_lista_offset_nombre], r12
	mov [rax + struct_lista_offset_first], rdx
	mov [rax + struct_lista_offset_last], rdx

	pop r12
	pop rbp
	ret

global string_proc_node_create
string_proc_node_create:
	push rbp
	mov rbp, rsp
	push rdi ;pusheo todos los parametros, ya que al no ser preservables, malloc podria romperlos
	push rsi
	push rdx

	mov rdi, struct_node_size ;pido memoria para almacenar la estructura de un nodo
	call malloc	

	pop rdx ;recupero el parametro
	pop rsi
	pop rdi 

	mov rcx, NULL ;rcx no debe ser preservado

	mov [rax + struct_node_offset_next], rcx
	mov [rax + struct_node_offset_previous], rcx
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
	push r12
	push r13

	mov r13, rdi ;muevo la lista a r13

	mov rdi, [r13 + struct_lista_offset_nombre]
	call free

	mov rdi, [r13 + struct_lista_offset_first] ;me paro en el primer nodo
	ciclo:
		cmp rdi, NULL ;si no hay mas nodos, ya libere todos (o no habia ninguno)
		JE fin_borrado_nodos
		mov r12, [rdi + struct_node_offset_next] ;antes de destruirlo, tomo el next
		call string_proc_node_destroy ;lo destruyo
		mov rdi, r12
	JMP ciclo

	fin_borrado_nodos: ;una vez liberados todos los nodos, libero la lista
	mov rdi, r13 ;muevo la lista otra vez a rdi
	mov r12, NULL
	mov [rdi + struct_lista_offset_first], r12
	mov [rdi + struct_lista_offset_last], r12
	call free

	pop r13
	pop r12
	pop rbp
	ret

global string_proc_node_destroy
string_proc_node_destroy:
	push rbp
	mov rbp, rsp
	push r12
	
	mov r12, NULL

	;en rdi tengo el puntero al nodo
	mov [rdi + struct_node_offset_next], r12
	mov [rdi + struct_node_offset_previous], r12
	mov [rdi + struct_node_offset_f], r12
	mov [rdi + struct_node_offset_g], r12

	call free

	pop r12
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
string_proc_list_add_node: ;se debe agregar el nodo al final de la lista
	push rbp
	mov rbp, rsp
	push r12
	;rdi -> puntero a lista
	;rsi -> f
	;rdx -> g
	;rcx -> type
	;para llamar al metodo node_create, debemos cambiar el orden de los parametros

	push rdi
	push rsi
	push rdx
	push rcx

	mov rdi, rsi ;f es el primer parametro
	mov rsi, rdx ;g es el segundo
	mov rdx, rcx ;type el tercero
	call string_proc_node_create

	pop rcx ;recupero los parametros en el orden original
	pop rdx
	pop rsi
	pop rdi
	
	mov r12, [rdi + struct_lista_offset_last] ;puntero al ultimo nodo de la lista
	cmp r12, NULL
	JE lista_vacia ;si r12 es null, la lista esta vacia

	;en rax tengo el nodo nuevo, en rdi la lista y en r12 un puntero al ultimo nodo
	mov [r12 + struct_node_offset_next], rax
	mov [rax + struct_node_offset_previous], r12
	mov [rdi + struct_lista_offset_last], rax
	JMP fin_metodo

	lista_vacia:
	mov [rdi + struct_lista_offset_first], rax
	mov [rdi + struct_lista_offset_last], rax
	
	fin_metodo:
	pop r12
	pop rbp
	ret

global string_proc_list_apply
string_proc_list_apply:
	ret
