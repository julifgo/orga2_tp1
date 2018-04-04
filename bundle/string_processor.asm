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
	%define struct_node_size 40 ;punteros next y prev: 8, direcciones memoria func: 8, enum: 4
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
	push rbp ;alineada
	mov rbp, rsp
	push r12 ;desalineada
	sub rsp, 8 ;alineada
	
	call str_copy
	mov r12, rax

	mov rdi, struct_lista_size ;pido memoria para almacenar la estructura de una lista
	call malloc
	
	mov rdx, NULL

	mov [rax + struct_lista_offset_nombre], r12
	mov [rax + struct_lista_offset_first], rdx
	mov [rax + struct_lista_offset_last], rdx

	add rsp, 8
	pop r12
	pop rbp
	ret

global string_proc_node_create
string_proc_node_create:
	push rbp ;alineada
	mov rbp, rsp
	push rdi ;desalineada
	push rsi ;alineada
	push rdx ;desalineada ;TODO. RESOLVER DUDA 1 PARA SABER SI LA PARTE ALTA DE ESTE REGISTRO PODRIA VENIR SUCIA
	sub rsp, 8 ;alineada

	mov rdi, struct_node_size ;pido memoria para almacenar la estructura de un nodo
	call malloc	

	xor rdx, rdx ;limpio rdx ya que ahi ira el enum de 4 bytes del tipo
	add rsp, 8
	pop rdx 
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
	push rbp ;alineada
	mov rbp, rsp
	push r12 ;desalineada
	push r13 ;alineada
	
	mov r12, rdi ;resguardo rdi para no perderlo luego del call
	
	call str_len ;uso la funcion auxiliar de c de longitud con el value que ya esta en rdi
	xor r13, r13 ;limpio r13 ya que str_len devuelve doubleword (unsigned)
	mov r13, rax ;muevo el length del value
	;es importante moverlo a un registro que deba preservar valor, sino str_copy o malloc podria pisarlo (por ejemplo si se usara rdx e vez de r13)

	mov rdi, r12
	call str_copy
	mov r12, rax
	
	mov rdi, struct_key_size
	call malloc

	mov [rax + struct_key_offset_length], r13
	mov [rax + struct_key_offset_value], r12

	pop r13
	pop r12
	pop rbp
	ret

global string_proc_list_destroy ;TODO. Chequear desde aca
string_proc_list_destroy:
	push rbp ;alineada
	mov rbp, rsp
	push r12 ;desalineada
	push r13 ;alineada

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
	push rbp ;alineada
	mov rbp, rsp
	push r12 ;desalineada
	sub rsp, 8 ;alineada
	
	mov r12, NULL

	;en rdi tengo el puntero al nodo
	mov [rdi + struct_node_offset_next], r12
	mov [rdi + struct_node_offset_previous], r12
	mov [rdi + struct_node_offset_f], r12
	mov [rdi + struct_node_offset_g], r12

	call free

	add rsp, 8
	pop r12
	pop rbp
	ret

global string_proc_key_destroy
string_proc_key_destroy:
	push rbp ;alineada
	mov rbp, rsp
	push rdi  ;desalineada ;resguardo el puntero a key, puesto que en rdi debo poner el value para liberarlo
	sub rsp, 8 ;alineada
	
	mov rdx, [rdi + struct_key_offset_value] ;leo el puntero a value
	mov rdi, rdx
	call free ;libero value
	
	add rsp, 8 ;desalineada
	pop rdi ;alineada

	mov rdx, 0
	mov [rdi + struct_key_offset_length], rdx
	mov rdx, NULL
	mov [rdi + struct_key_offset_value], rdx

	call free

	pop rbp
	ret

global string_proc_list_add_node
string_proc_list_add_node: ;se debe agregar el nodo al final de la lista
	push rbp ;alineada
	mov rbp, rsp
	push r12 ;desalineada
	;rdi -> puntero a lista
	;rsi -> f
	;rdx -> g
	;rcx -> type
	;para llamar al metodo node_create, debemos cambiar el orden de los parametros

	push rdi ;alineada
	push rsi ;desalineada
	push rdx ;alineada 
	push rcx ;desalineada
	sub rsp, 8 ;alineada

	mov rdi, rsi ;f es el primer parametro
	mov rsi, rdx ;g es el segundo
	mov rdx, rcx ;type el tercero
	call string_proc_node_create

	add rsp, 8 ;desalineada
	pop rcx ;alineada ;recupero los parametros en el orden original
	pop rdx ;desalineada
	pop rsi ;alineada
	pop rdi ;desalineada
	sub rsp, 8 ;alineada
	
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
	add rsp, 8
	pop r12
	pop rbp
	ret

global string_proc_list_apply
string_proc_list_apply:
	push rbp ;alineada
	mov rbp, rsp
	push r12 ;desalineada
	push r13 ;alineada
	push r14 ;desalineada
	sub rsp, 8 ;alineada

	;rdi -> lista
	;rsi -> key
	;rdx -> bool

	mov r13, rdi ;muevo la lista a r13, para dejar rdi para los call
	cmp rdx, FALSE
	JE decode ;si encode==false => decode
		mov r12, [r13 + struct_lista_offset_first]
		ciclo_encode:
		CMP r12, NULL
		JE fin_apply
		mov rdi, rsi ;como rdi no es preservable, lo vuelvo a asignar en cada iteracion del ciclo
		mov r14, [r12 + struct_node_offset_f]
		call r14
		mov r12, [r12 + struct_node_offset_next]
		JMP ciclo_encode
	decode:
		mov r12, [r13 + struct_lista_offset_last]
		ciclo_decode:
		CMP r12, NULL
		JE fin_apply
		mov rdi, rsi
		mov r14, [r12 + struct_node_offset_g]
		call r14
		mov r12, [r12 + struct_node_offset_previous]
		JMP ciclo_decode

	fin_apply:
	add rsp, 8
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
