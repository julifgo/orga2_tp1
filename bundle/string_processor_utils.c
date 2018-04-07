#include <stdbool.h>
#include <stdio.h>
#include "string_processor.h"
#include "string_processor_utils.h"

/**
* Chequea si n es numero primo
*/
bool isPrime(uint32_t n){
	if(n <= 1)
		return false;
	
	uint32_t i = 2;
	while (i < n){
		if(n%i == 0)
			return false;
		i++;
	}
	return true;
}


/**
*	Debe devolver el largo de la lista pasada por parámetro
*/
uint32_t string_proc_list_length(string_proc_list* list){ 
	uint32_t len = 0;
	string_proc_node *nodo = list->first;
	while (nodo != NULL)
	{
		len++;
		nodo = nodo->next; //el next del ultimo es NULL
	}
	return len; 
}


/**
*	Debe insertar el nodo con los parámetros correspondientes en la posición indicada por index desplazando en una
*	posición hacia adelante los nodos sucesivos en caso de ser necesario, la estructura de la lista debe ser
*	actualizada de forma acorde
*	si index es igual al largo de la lista debe insertarlo al final de la misma
*	si index es mayor al largo de la lista no debe insertar el nodo
*	debe devolver true si el nodo pudo ser insertado en la lista, false en caso contrario
*/
bool string_proc_list_add_node_at(string_proc_list* list, string_proc_func f, string_proc_func g, string_proc_func_type type, uint32_t index){ 
	/*Si index == list_length => inserta al final. Siguiendo esa lógica,si el index es 0, se inserta al principio. Si es 1, se inserta segundo, si es list_length -1 anteultimo*/
	if(index > string_proc_list_length(list))
		return false; 
		
	if(string_proc_list_length(list) == 0){
		string_proc_list_add_node(list, f, g, type);
		return true;
	}
	
	string_proc_node* node	= string_proc_node_create(f, g, type);
	if(index==0){
		//INSERTAR AL PPIO
		string_proc_node* firstNode = list->first;
		firstNode->previous = node;
		node->next = firstNode;
		list->first = node;
		return true;
	}
	if(index==string_proc_list_length(list)){
		//INSERTAR AL FINAL
		string_proc_node* lastNode = list->last;
		lastNode->next = node;
		node->previous = lastNode;
		list->last = node;
		return true;
	}
	//CASO CONTRARIO. RECORRER LA LISTA A LA POSICION DESEADA
	uint32_t i = 0;
	string_proc_node* current_node	= list->first;
	while(i < index){
		current_node = current_node->next;
		i++;
	}
	//a la salida del ciclo, node debe ser insertado como previo a current_node
	node->previous = current_node->previous;
	current_node->previous->next = node;
	current_node->previous = node;
	node->next = current_node;
	return true;
}


/**
*	Debe eliminar el nodo que se encuentra en la posición indicada por index de ser posible
*	la lista debe ser actualizada de forma acorde y debe devolver true si pudo eliminar el nodo o false en caso contrario
*/
bool string_proc_list_remove_node_at(string_proc_list* list, uint32_t index){
	if(index >= string_proc_list_length(list))
		return false; 
	
	uint32_t i = 0;
	string_proc_node* current_node	= list->first;
	while(i < index){
		current_node = current_node->next;
		i++;
	}
	if(current_node->next == NULL){//era el ultimo, se actualiza last
		list->last = current_node->previous;
	}
	else
		current_node->next->previous = current_node->previous;
	if(current_node->previous == NULL){//era el primero, se actualiza el first
		list->first = current_node->next;
	}
	else
		current_node->previous->next = current_node->next;
	//redefino los nexts y lasts de los nodos previous y next
	
	free(current_node);

	return true;
}


/**
*	Debe devolver una copia de la lista pasada por parámetro copiando los nodos en el orden inverso
*/
string_proc_list* string_proc_list_invert_order(string_proc_list* list){ 
	string_proc_list* new_list		= string_proc_list_create(list->name);
	string_proc_node* current_node	= list->last;
	while(current_node != NULL){
		string_proc_list_add_node(new_list, current_node->f, current_node->g, current_node->type);
		current_node	= current_node->previous;
	}
	return new_list;
}

//TODO: debe implementar
/**
*	Hace una llamada sucesiva a los nodos de la lista pasada por parámetro siguiendo la misma lógica
*	que string_proc_list_apply pero comienza imprimiendo una línea 
*	"Encoding key 'valor_de_la_clave' through list nombre_de_la_list\n"
* 	y luego por cada aplicación de una función f o g escribe 
*	"Applying function at [direccion_de_funcion] to get 'valor_de_la_clave'\n"
*/
void string_proc_list_apply_print_trace(string_proc_list* list, string_proc_key* key, bool encode, FILE* file){
	fprintf(file,"Decoding key '%s' through list %s\n", key->value, list->name);
	if(encode){
		string_proc_node* current_node	= list->first;
		while(current_node != NULL){
			current_node->f(key);
			//void (*pepe) (string_proc_key*) = current_node->f;

			//void *pepa = (void *)current_node->f;

			//PARA DEBUGGEAR, AL CREAR UN NODO, VER SI PODEMOS VER CUAL ES LA POSICION DE MEMORIA QUE
			//GUARDA EN NODE->F, ESA DEBERIA SER LA QUE TENEMOS QUE MOSTRAR.
			//PORQUE PUEDE SER QUE ESTEMOS MOSTRANDO LA POSICION DE MEMORIA DEL STRUCT+OFFSET_F
			fprintf(file,"Applying function at [%p] to get '%s'\n", current_node->f,key->value);
			current_node = current_node->next;
		}
	}else{
		string_proc_node* current_node	= list->last;
		while(current_node != NULL){
			current_node->g(key);
			current_node = current_node->previous;
		}
	}
}


/**
*	Debe desplazar en dos posiciones hacia adelante el valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición impar, resolviendo los excesos de representación por saturación
*/
void saturate_2_odd(string_proc_key* key){
	uint32_t i;
	for(i = 1; i < key->length; i+=2){ //si la key tuviese un caracter, no entra al ciclo lo cual es correcto
		key->value[i] = saturate_int(((int32_t)key->value[i]) + 2);
	}
}


/**
*	Debe desplazar en dos posiciones hacia atrás el valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición impar, resolviendo los excesos de representación por saturación
*/
void unsaturate_2_odd(string_proc_key* key){
	uint32_t i;
	for(i = 1; i < key->length; i+=2){
		key->value[i] = saturate_int(((int32_t)key->value[i]) - 2);
	}
}

//TODO: debe implementar
/**
*	Debe desplazar en tantas posiciones como sea la posición hacia adelante del valor de cada caracter de la clave pasada por parámetro
*uint32_t i;
	for(i = 0; i < key->length; i++){
		if(isPrime(i))
			key->value[i] = wrap_around_int(((int32_t)key->value[i]) + i);
	}	si el mismo se encuentra en una posición que sea un número primo, resolviendo los excesos de representación con wrap around
*/
void shift_position_prime(string_proc_key* key){
	uint32_t i;
	for(i = 0; i < key->length; i++){
		if(isPrime(i))
			key->value[i] = wrap_around_int(((int32_t)key->value[i]) + i);
	}
}

//TODO: debe implementar
/**
*	Debe desplazar en tantas posiciones como sea la posición hacia atrás del valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición que sea un número primo, resolviendo los excesos de representación con wrap around
*/
void unshift_position_prime(string_proc_key* key){
	uint32_t i;
	for(i = 0; i < key->length; i++){
		if(isPrime(i))
			key->value[i] = wrap_around_int(((int32_t)key->value[i]) - i);
	}
}


