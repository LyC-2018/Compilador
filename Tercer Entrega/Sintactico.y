%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE *yyin;
char *yytext;
extern int yylineno;

/**** INICIO VARIABLES ****/
char tipoActual[10]={""};
char listaVariables[10][20]={""};
int variableActual=0;
void reinicioVariables();
/**** FIN VARIABLES ****/


/**** INICIO TERCETOS ****/

int IndAsignacion;
int IndExpresion;
int IndTermino;
int IndFactor;
int IndInlist;
int IndEntrada;
int IndSalida;

struct terceto {
	char *uno;
	char *dos;
	char *tres;
};
struct terceto tercetos[1000];
int terceto_index = 0;

int crearTerceto_ccc(char *uno, char *dos, char *tres);
int crearTerceto_cci(char *uno, char *dos, int tres);
int crearTerceto_cii(char *uno, int dos, int tres);
int crearTerceto_fcc(float uno, char *dos, char *tres);
int crearTerceto_icc(int uno, char *dos, char *tres);
int crearTerceto_cic(char *uno, int dos, char *tres);

void save_tercetos();
/**** FIN TERCETOS ****/

/**** INICIO INLIST ****/
int inlist_indice_id;
int inlist_saltos_a_completar[15];
int inlist_cant_saltos;
int inlist_tengo_que_completar[15];
int inlist_index;

int index_inlist_negados = 0;
struct cond_inlist_negado {
	int tiene_inlist_negado;
	int cantidad_saltos;
	int posiciones[15];
};
struct cond_inlist_negado inlist_negados[15];

void completar_salto_si_es_inlist_negado(int pos);
void guardar_condicion_no_tiene_inlist_negado();
/**** FIN INLIST ****/

/**** INICIO COMPARACION ****/
char valor_comparacion[3];
int IndComparacion;
int saltos_and_a_completar[6];
int and_index = 0;
void completar_salto_si_es_comparacion_AND(int pos);
int pos_a_completar_OR;
int es_negado = 0;
/**** FIN COMPARACION ****/

/**** INICIO IF ****/
int if_salto_a_completar;
int if_saltos[6];
int if_index = 0;
void if_guardar_salto(int pos);
void if_completar_ultimo_salto_guardado_con(int pos);
/**** FIN IF ****/

/**** INICIO AVERAGE ****/
int IndAvg;
int IndExpresionAvg;
int cantExpAvg;
/**** FIN AVERAGE ****/

/**** INICIO WHILE ****/
int while_pos_inicio;
int while_salto_a_completar;
int while_pos_a_completar[11];
int while_index = 0;
void while_guardar_pos(int pos);
/**** FIN IF ****/

/**** INICIO PILA ****/
const int tamPila = 100;

typedef struct {
    int pila[100];
    int tope;
} Pila;

void crearPila( Pila *p);
int pilaLLena( Pila *p );
int pilaVacia( Pila *p);
int ponerEnPila(Pila *p, int dato);
int sacarDePila(Pila *p);

Pila pilaAverage;
Pila pilaCantExpAvg;
Pila pilaExpresion;
Pila pilaTermino;
/**** FIN PILA ****/

/**** INICIO EXP NUMERICA ****/

int buscarTipoTS(char* nombreVar);
void verificarTipoDato(int tipo);
void reiniciarTipoDato();
int tipoDatoActual = -1;

int Integer = 1;
int Float = 2;
int String = 3;


/**** FIN EXP NUMERICA ****/

/**** Inicio assembler ****/
void genera_asm();
void generaSegmDatosAsm(FILE*);
char* getCodOp(char*);
/**** Fin assembler ****/
%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <strVal>CTE_STRING <realVal>CTE_REAL
%token ASIG OP_SUMA OP_RESTA OP_MULT OP_DIV
%token MENOR MAYOR IGUAL DISTINTO MENOR_IGUAL MAYOR_IGUAL
%token INLIST AVG
%token WHILE ENDWHILE
%token IF ELSE ENDIF
%token P_A P_C C_A C_C
%token COMA PUNTO_COMA DOS_PUNTOS
%token AND OR NOT
%token INT FLOAT STRING
%token DECVAR ENDDEC
%token READ WRITE

%start start

%%

start: programa { genera_asm(); printf("\n\n\tCOMPILACION EXITOSA!!\n\n\n"); }
	 |			{ printf("\n El archivo 'Prueba.Txt' no tiene un programa\n"); }
	 ;

programa: declaracion { printf("Declaracion OK\n"); } bloque
        | bloque
		;

declaracion: DECVAR variables ENDDEC
		   | DECVAR ENDDEC
		   ;

variables: variables listavar DOS_PUNTOS tipo { guardarTipos(variableActual, listaVariables, tipoActual); reinicioVariables(); }
	     | listavar DOS_PUNTOS tipo { guardarTipos(variableActual, listaVariables, tipoActual); reinicioVariables(); }
         ;

listavar: listavar COMA ID { strcpy(listaVariables[variableActual++],$3); insertar_id_en_ts($3); }
	    | ID { strcpy(listaVariables[variableActual++],$1); insertar_id_en_ts($1); }
        ;

tipo: INT    { strcpy(tipoActual,"INT"); }
    | FLOAT  { strcpy(tipoActual,"REAL"); }
	| STRING { strcpy(tipoActual,"STRING"); }
	;

bloque: sentencia
	  | bloque sentencia
	  ;

sentencia: asignacion { printf("Asignacion OK\n"); }
		 | iteracion  { printf("Iteracion OK\n"); }
		 | decision   { printf("Decision OK\n"); }
		 | entrada    { printf("Entrada OK\n"); }
		 | salida     { printf("Salida OK\n"); }
		 ;

asignacion: ID ASIG expresion { int tipo = buscarTipoTS($1);
								verificarTipoDato(tipo);
								reiniciarTipoDato();
								IndAsignacion = crearTerceto_cii("=", crearTerceto_ccc($1, "",""), IndExpresion);
							  }
		  ;

iteracion: WHILE P_A { while_guardar_pos(terceto_index); }
			condicion P_C { if(strcmp(valor_comparacion, "") != 0) while_guardar_pos(crearTerceto_ccc(valor_comparacion, "", "")); else while_index++; }
			bloque ENDWHILE {
				char *salto = (char*) malloc(sizeof(int));
				itoa(terceto_index+1, salto, 10);
				tercetos[while_pos_a_completar[while_index]].dos = salto;
				while_index--;
				crearTerceto_cic("BI", while_pos_a_completar[while_index], "");
				while_index--;
				completar_salto_si_es_comparacion_AND(terceto_index);
				completar_salto_si_es_inlist_negado(terceto_index);
				}
		 ;

decision: IF P_A condicion P_C { if(strcmp(valor_comparacion, "") != 0) if_guardar_salto(crearTerceto_ccc(valor_comparacion, "", "")); else if_index++; }
			 decision_bloque
		;

decision_bloque:
		  bloque ENDIF {
			if_completar_ultimo_salto_guardado_con(terceto_index);
			completar_salto_si_es_comparacion_AND(terceto_index);
			completar_salto_si_es_inlist_negado(terceto_index);
			}
		| bloque { if_completar_ultimo_salto_guardado_con(terceto_index+1);
			       completar_salto_si_es_comparacion_AND(terceto_index+1);
				   if_guardar_salto(crearTerceto_ccc("BI", "",""));
				   completar_salto_si_es_inlist_negado(terceto_index);
				}
		  ELSE bloque ENDIF { if_completar_ultimo_salto_guardado_con(terceto_index); }
		;

condicion: comparacion { and_index++; saltos_and_a_completar[and_index] = -1; guardar_condicion_no_tiene_inlist_negado(); }
         | comparacion { and_index++; saltos_and_a_completar[and_index] = crearTerceto_ccc(valor_comparacion, "", "");  guardar_condicion_no_tiene_inlist_negado(); } AND comparacion
		 | comparacion {
				and_index++; saltos_and_a_completar[and_index] = -1;
				crearTerceto_cic(valor_comparacion, terceto_index+2, ""); // salto a la prox comparación
				pos_a_completar_OR = crearTerceto_ccc("BI","",""); // tengo que saltar al final de la prox comparacion
				guardar_condicion_no_tiene_inlist_negado();
				}
			OR comparacion {
				char *salto = (char*) malloc(sizeof(int));
				itoa(terceto_index+1, salto, 10);
				tercetos[pos_a_completar_OR].dos = (char*) malloc(sizeof(char)*strlen(salto));
				strcpy(tercetos[pos_a_completar_OR].dos, salto);
			}
		 | NOT { guardar_condicion_no_tiene_inlist_negado(); es_negado = 1; } comparacion { es_negado = 0; };
		 ;

comparacion: expresion { IndComparacion = IndExpresion; } MENOR expresion { reiniciarTipoDato(); crearTerceto_cii("CMP", IndComparacion, IndExpresion);
				if(es_negado == 0) { strcpy(valor_comparacion, "BGE"); } else { strcpy(valor_comparacion, "BLT"); }
			 }
		   | expresion { IndComparacion = IndExpresion; } MENOR_IGUAL expresion { reiniciarTipoDato(); crearTerceto_cii("CMP", IndComparacion, IndExpresion);
				if(es_negado == 0) { strcpy(valor_comparacion, "BGT"); } else { strcpy(valor_comparacion, "BLE"); }
			 }
		   | expresion { IndComparacion = IndExpresion; } MAYOR expresion       { reiniciarTipoDato(); crearTerceto_cii("CMP", IndComparacion, IndExpresion);
		   		if(es_negado == 0) { strcpy(valor_comparacion, "BLE"); } else { strcpy(valor_comparacion, "BGT"); }
			 }
		   | expresion { IndComparacion = IndExpresion; } MAYOR_IGUAL expresion { reiniciarTipoDato(); crearTerceto_cii("CMP", IndComparacion, IndExpresion);
		   		if(es_negado == 0) { strcpy(valor_comparacion, "BLT"); } else { strcpy(valor_comparacion, "BGE"); }
			 }
		   | expresion { IndComparacion = IndExpresion; } IGUAL expresion       { reiniciarTipoDato(); crearTerceto_cii("CMP", IndComparacion, IndExpresion);
		   		if(es_negado == 0) { strcpy(valor_comparacion, "BNE"); } else { strcpy(valor_comparacion, "BEQ"); }
			 }
		   | expresion { IndComparacion = IndExpresion; } DISTINTO expresion    { reiniciarTipoDato(); crearTerceto_cii("CMP", IndComparacion, IndExpresion);
		   		if(es_negado == 0) { strcpy(valor_comparacion, "BEQ"); } else { strcpy(valor_comparacion, "BNE"); }
			 }
		   | inlist { if (es_negado == 0) { strcpy(valor_comparacion, "BI"); } else { strcpy(valor_comparacion, ""); inlist_negados[index_inlist_negados].tiene_inlist_negado = 1; } }
		   ;

average: AVG P_A C_A avg_expresiones C_C P_C { 
											   reiniciarTipoDato();
											   if(cantExpAvg == 1){
												IndAvg = IndExpresionAvg ; // dividir por uno te daria lo mismo y asi te ahorras un terceto
                                               }
                                               else{
                                                   cantExpAvg = crearTerceto_icc(cantExpAvg, "",""); //este terceto se podria optimizar
                                                   IndAvg = crearTerceto_cii("/", IndExpresionAvg, cantExpAvg) ; // este seria el resultado del average
                                                }
                                                //saca todo de la pila
                                                IndExpresionAvg = sacarDePila(&pilaAverage);
                                                cantExpAvg = sacarDePila(&pilaCantExpAvg);
                                                IndExpresion = sacarDePila(&pilaExpresion);
                                                IndTermino = sacarDePila(&pilaTermino);
                                            }
		;

avg_expresiones: { // pone todo en la pila antes de entrar al average para que no afecte nada lo que se haga adentro del average
                   ponerEnPila(&pilaExpresion, IndExpresion);
                   ponerEnPila(&pilaTermino, IndTermino);
                   ponerEnPila(&pilaCantExpAvg, cantExpAvg);
                   ponerEnPila(&pilaAverage, IndExpresionAvg);
                 }
                 expresion {
							 reiniciarTipoDato();
							 IndExpresionAvg = IndExpresion; // el subtotal va  a ser el primer numero
                             cantExpAvg = 1;
                           }
			     | avg_expresiones  COMA expresion {
													 reiniciarTipoDato();
													 IndExpresionAvg = crearTerceto_cii("+", IndExpresionAvg, IndExpresion); //el subtotal va a ser el subtotal anterior mas la expresion actual
                                                     cantExpAvg++;
                                                   }
			   ;

inlist: INLIST P_A ID { 
						int tipo = buscarTipoTS($3);
						verificarTipoDato(tipo);
						existe_en_ts($3); inlist_indice_id = crearTerceto_ccc($3, "", "");
					  } 
		COMA C_A inlist_expresiones C_C P_C  {	
											reiniciarTipoDato();
											// aca completo los saltos por la pos actual de tercetos +1 (por el BI)
											if (es_negado == 0) {
												int i;
												for (i=0; i<inlist_cant_saltos; i++) {
													char *salto = (char*) malloc(sizeof(int));
													itoa(terceto_index+1, salto, 10);
													tercetos[inlist_saltos_a_completar[i]].dos = salto;
												}
											}
										}
	  ;

inlist_expresiones: expresion {
								inlist_cant_saltos = 0;
								IndInlist = crearTerceto_cii("CMP", inlist_indice_id, IndExpresion);
								int pos;
								pos = crearTerceto_ccc("BEQ", "", "");
								inlist_saltos_a_completar[inlist_cant_saltos] = pos;
								inlist_cant_saltos++;
								if (es_negado == 1) {
									inlist_negados[index_inlist_negados].cantidad_saltos = inlist_cant_saltos;
									inlist_negados[index_inlist_negados].posiciones[inlist_cant_saltos-1] = pos;
								}

								}
		          | inlist_expresiones PUNTO_COMA expresion {
																IndInlist = crearTerceto_cii("CMP", inlist_indice_id, IndExpresion);
																int pos = crearTerceto_ccc("BEQ", "", "");
																inlist_saltos_a_completar[inlist_cant_saltos] = pos;
																inlist_cant_saltos++;
																if (es_negado == 1) {
																	inlist_negados[index_inlist_negados].cantidad_saltos = inlist_cant_saltos;
																	inlist_negados[index_inlist_negados].posiciones[inlist_cant_saltos-1] = pos;
																}
															}
		          ;

expresion: expresion OP_SUMA termino  { IndExpresion = crearTerceto_cii("+", IndExpresion, IndTermino); }
		 | expresion OP_RESTA termino { IndExpresion = crearTerceto_cii("-", IndExpresion, IndTermino); }
		 | termino  { IndExpresion = IndTermino; }
		 ;

termino: termino OP_MULT factor  { IndTermino = crearTerceto_cii("*", IndTermino, IndFactor); }
	   | termino OP_DIV factor   { IndTermino = crearTerceto_cii("/", IndTermino, IndFactor); }
	   | factor                  { IndTermino = IndFactor; }
	   ;

factor: ID	               { int tipo = buscarTipoTS(yylval.strVal);
							 verificarTipoDato(tipo);
							 IndFactor = crearTerceto_ccc($1, "", "");
						   }
	  | constante
	  
	  | P_A 			   { ponerEnPila(&pilaTermino, IndTermino);
                             ponerEnPila(&pilaExpresion, IndExpresion);
						   }
      expresion P_C        {
                            IndFactor = IndExpresion;
                            IndExpresion = sacarDePila(&pilaExpresion);
                            IndTermino = sacarDePila(&pilaTermino);
                           }
	  | average            { verificarTipoDato(Float);
							 printf("AVG OK\n"); IndFactor = IndAvg;
						   }
	  ;


constante: CTE_INT    { verificarTipoDato(Integer);
						IndFactor = crearTerceto_icc($1, "", "");
					  }
         | CTE_STRING { IndFactor = crearTerceto_ccc($1, "", ""); }
		 | CTE_REAL   { 
						verificarTipoDato(Float);
						IndFactor = crearTerceto_fcc($1, "", "");
					  }
		 ;

entrada: READ ID			{ existe_en_ts($2);
							  IndEntrada = crearTerceto_ccc($2, "", ""); 
							  crearTerceto_cic("READ",IndEntrada,"");
							}
       ;

salida: WRITE CTE_STRING	{ IndSalida = crearTerceto_ccc($2, "", "");
							  crearTerceto_cic("WRITE",IndSalida,"");
							}
      | WRITE ID 			{ existe_en_ts($2); }
	  ;

%%

int main(int argc,char *argv[])
{

  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
    crearPila(&pilaAverage);
    crearPila(&pilaCantExpAvg);
    crearPila(&pilaExpresion);
    crearPila(&pilaTermino);
	yyparse();
	//mostrar_ts();
	save_reg_ts();
	save_tercetos();
  }
  fclose(yyin);
  return 0;
}

int yyerror(char *errMessage)
{
   printf("(!) ERROR en la linea %d: %s\n",yylineno,errMessage);
   fprintf(stderr, "Fin de ejecucion.\n");
   system ("Pause");
   exit (1);
}

void reinicioVariables() {
	variableActual=0;
    strcpy(tipoActual,"");
}


/* Tercetos */
int crearTerceto_ccc(char *uno, char *dos, char *tres) {
	struct terceto terc;
	int index = terceto_index;
	terc.uno = malloc(sizeof(char)*strlen(uno)+1);
	strcpy(terc.uno, uno);
	terc.dos = malloc(sizeof(char)*strlen(dos)+1);
	strcpy(terc.dos, dos);
	terc.tres = malloc(sizeof(char)*strlen(tres)+1);
	strcpy(terc.tres, tres);
	tercetos[index] = terc;
	terceto_index++;
	return index; // devuelvo la pos del terceto creado
}

int crearTerceto_cci(char *uno, char *dos, int tres) {
	char *tres_char = (char*) malloc(sizeof(int));
	itoa(tres, tres_char, 10);

	return crearTerceto_ccc(uno, dos, tres_char);
}

int crearTerceto_cii(char *uno, int dos, int tres) {
	struct terceto terc;
	int index = terceto_index;

	char *dos_char = (char*) malloc(sizeof(int));
	itoa(dos, dos_char, 10);

	return crearTerceto_cci(uno, dos_char, tres);
}

int crearTerceto_fcc(float uno, char *dos, char *tres) {
	char *uno_char = (char*) malloc(sizeof(float));
	snprintf(uno_char, sizeof(float), "%f", uno);

	return crearTerceto_ccc(uno_char, dos, tres);
}

int crearTerceto_icc(int uno, char *dos, char *tres) {
	char *uno_char = (char*) malloc(sizeof(int));
	itoa(uno, uno_char, 10);

	return crearTerceto_ccc(uno_char, dos, tres);
}

int crearTerceto_cic(char *uno, int dos, char *tres) {
	char *dos_char = (char*) malloc(sizeof(int));
	itoa(dos, dos_char, 10);

	return crearTerceto_ccc(uno, dos_char, tres);
}

void save_tercetos() {
	FILE *file = fopen("Intermedia.txt", "a");

	if(file == NULL)
	{
    	printf("(!) ERROR: No se pudo abrir el txt correspondiente a la generacion de codigo intermedio\n");
	}
	else
	{
		int i = 0;
		for (i;i<terceto_index;i++) {
			// printf("%d (%s, %s, %s)\n", i, tercetos[i].uno, tercetos[i].dos, tercetos[i].tres);
			fprintf(file, "%d (%s, %s, %s)\n", i, tercetos[i].uno, tercetos[i].dos, tercetos[i].tres);
		}
		fclose(file);
	}
}

/* Funcion para simil apilar las posiciones y permitir ifs anidados */
void if_guardar_salto(int pos) {
	if (if_index < 6)
	{
		if_index++;
		if_saltos[if_index] = pos;
	}
	else
	{
		yyerror("No se puede tener más de 5 ifs anidados\n");
	}
}

/* Funcion para simil desapilar y completar las posiciones del if */
void if_completar_ultimo_salto_guardado_con(int pos) {
	char *salto = (char*) malloc(sizeof(int));
	itoa(pos, salto, 10);
	tercetos[if_saltos[if_index]].dos = (char*) malloc(sizeof(char)*strlen(salto));
	strcpy(tercetos[if_saltos[if_index]].dos, salto);
	if_index--;
}

/* Funcion para simil apilar las pos del while */
void while_guardar_pos(int pos) {
	if (if_index < 11) // se usa del 1 al 10 y se ocupan dos pos por cada while
	{
		while_index++;
		while_pos_a_completar[while_index] = pos;
	}
	else
	{
		yyerror("No se puede tener más de 5 whiles anidados");
	}
}

/* Si el flag de AND esta prendido completa la pos guardada y vuelve el flag a off */
void completar_salto_si_es_comparacion_AND(int pos) {
		if (saltos_and_a_completar[and_index] == -1){
			and_index--; // flags usados para mantener la correlatividad de la pila de if con la de and
		}
		else {
			char *salto = (char*) malloc(sizeof(int));
			itoa(pos, salto, 10);
			tercetos[saltos_and_a_completar[and_index]].dos = (char*) malloc(sizeof(char)*strlen(salto));
			strcpy(tercetos[saltos_and_a_completar[and_index]].dos, salto);
			and_index--;
		}

}

/* Funcion auxiliar para completar caso particular del inlist */
void completar_salto_si_es_inlist_negado(int pos) {
	if (inlist_negados[index_inlist_negados].tiene_inlist_negado != -1) {
		int i;
		for (i=0; i < inlist_negados[index_inlist_negados].cantidad_saltos; i++) {
			char *salto = (char*) malloc(sizeof(int));
			itoa(terceto_index, salto, 10);
			tercetos[inlist_negados[index_inlist_negados].posiciones[i]].dos = salto;
		}
		index_inlist_negados--;
	}
	else {
		index_inlist_negados--;
	}
}

void guardar_condicion_no_tiene_inlist_negado () {
	struct cond_inlist_negado cond;
	cond.tiene_inlist_negado = -1;
	cond.cantidad_saltos = 0;

	index_inlist_negados++;
	inlist_negados[index_inlist_negados] = cond;
}

int buscarTipoTS(char* nombreVar) {

	int pos = nombre_existe_en_ts(nombreVar);
	
	if (pos == -1) {
		yyerror("La variable no fue declarada");
	}
	
	return tipoDeDato(pos);

}

void verificarTipoDato(int tipo) {

	if(tipoDatoActual == -1) {
		tipoDatoActual = tipo;
		return;
	}
	
	if(tipoDatoActual != tipo) {
		yyerror("No se admiten operaciones aritmeticas con tipo de datos distintos");
	}
	
}

void reiniciarTipoDato() {
	tipoDatoActual = -1;
}

/* PILA */

void crearPila( Pila *p){
    p->tope = 0;
}

int pilaLLena( Pila *p ){
    return p->tope == tamPila;
}

int pilaVacia( Pila *p){
    return p->tope == tamPila;
}

int ponerEnPila(Pila *p, int dato){
    if( p->tope == 100){
        return 0;
    }
    p->pila[p->tope] = dato;
    p->tope++;
    return 1;
}

int sacarDePila(Pila *p){
    if( p->tope == 0){
        return 0;
    }
    p->tope--;
    return p->pila[p->tope];
}

/************************************************************************************************************/

void genera_asm()
{
	int cont=0;
	char* file_asm = "Final.asm";
	FILE* pf_asm;
	
	 if((pf_asm = fopen(file_asm, "w")) == NULL)
     {
               printf("Error al generar el asembler \n");
               exit(1);
     }
	 /* generamos el principio del assembler, que siempre es igual */

	 fprintf(pf_asm, "include macros2.asm\n");
	 fprintf(pf_asm, "include number.asm\n");
	 fprintf(pf_asm, ".MODEL	LARGE \n");
	 fprintf(pf_asm, ".386\n");
	 fprintf(pf_asm, ".STACK 200h \n");

	 fprintf(pf_asm, ".CODE \n");
	 fprintf(pf_asm, "MAIN:\n");
	 fprintf(pf_asm, "\n");

    fprintf(pf_asm, "\n");
    fprintf(pf_asm, "\t MOV AX,@DATA 	;inicializa el segmento de datos\n");
    fprintf(pf_asm, "\t MOV DS,AX \n");
    fprintf(pf_asm, "\t MOV ES,AX \n");
    fprintf(pf_asm, "\t FNINIT \n");;
    fprintf(pf_asm, "\n");



	/*generamos el final */
	fprintf(pf_asm, "\t mov AX, 4C00h \t ; Genera la interrupcion 21h\n");
	fprintf(pf_asm, "\t int 21h \t ; Genera la interrupcion 21h\n");

	generaSegmDatosAsm(pf_asm);

	fprintf(pf_asm, "END MAIN\n");
	fclose(pf_asm);


}

/************************************************************************************************************/
void generaSegmDatosAsm(FILE* pf_asm)
{
	int i;

	fprintf(pf_asm, "\n.DATA \n");


	fprintf(pf_asm, "\t_NEWLINE 	db 	0Dh,0Ah,'$'\t;salto de linea\n");
	/*for(i=0; i<getCountTS(); i++)
	{

			if(!strcmp(getTipo(i), "REAL")||!strcmp(getTipo(i), "INT"))
			{
				fprintf(pf_asm, "\t%s dd ?\t;Declaracion de Variable Numerica\n", getNombreAsm(i));
			}
			else if(!strcmp(getTipo(i), "STR"))
			{
				fprintf(pf_asm, "\t%s db 30 dup (?),\"$\"\t;Declaracion de Variable String\n", getNombreAsm(i));
			}
			else if(!strcmp(getTipo(i), "CTE_STRING")||!strcmp(getTipo(i), "CONSSTRING"))
			{
				fprintf(pf_asm, "\t%s db \"%s\", \"$\", 30 dup (?)\t;Declaracion de Constant String\n", getNombreAsm(i), getValor(i));
			}
			else if(!strcmp(getTipo(i), "CTE_REAL")||!strcmp(getTipo(i), "CTE_INT")||!strcmp(getTipo(i), "CONSNUMBER"))
			{
				if(strstr(getValor(i),".")){
					fprintf(pf_asm, "\t%s dd %s\t;Declaracion de Constant Number\n", getNombreAsm(i), getValor(i));
				}else{
					fprintf(pf_asm, "\t%s dd %s.0\t;Declaracion de Constant Number\n", getNombreAsm(i), getValor(i));
				}
			}
		}*/
}

/************************************************************************************************************/
char* getCodOp(char* token)
{
	if(!strcmp(token, "+"))
	{
		return "FADD";
	}
	else if(!strcmp(token, "="))
	{
		return "MOV";
	}
	else if(!strcmp(token, "-"))
	{
		return "FSUB";
	}
	else if(!strcmp(token, "*"))
	{
		return "FMUL";
	}
	else if(!strcmp(token, "/"))
	{
		return "FDIV";
	}
	else if(!strcmp(token, "BNE")) // revisar los saltos
	{
		return "JNE";
	}
	else if(!strcmp(token, "BEQ"))
	{
		return "JE";
	}
	else if(!strcmp(token, "BBE"))
	{
		return "JAE";
	}
	else if(!strcmp(token, "BBT"))
	{
		return "JNA";
	}
	else if(!strcmp(token, "BLE"))
	{
		return "JBE";
	}
	else if(!strcmp(token, "BLT"))
	{
		return "JNB";
	}
	else if (!strcmp(token, "BI")) {
		return "JMP";
	}
}

