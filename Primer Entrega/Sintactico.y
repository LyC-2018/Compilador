%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <float.h>
#include <limits.h>
#include "y.tab.h"

FILE *yyin;
char *yytext;

/* FUNCIONES */
int validarInt(int entero);
int validarString(char *str);
int validarReal(float flotante);
int validarID(char *str);

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
%token COMA PUNTO_COMA
%token AND OR

%%

start: programa { printf("\n\n\tCOMPILACION EXITOSA!!\n\n\n"); }
		;

programa: sentencia 
		| programa sentencia
		;
		
sentencia: asignacion { printf("Asignacion OK\n"); }
		 | iteracion { printf("Iteracion OK\n"); }
		 | decision { printf("Seleccion OK\n"); }
		 | average { printf("AVG OK\n"); }
		 ;
		 
asignacion: ID ASIG expresion
		  ;

iteracion: WHILE P_A condicion P_C programa ENDWHILE
		 ;
		
decision: IF P_A condicion P_C programa ENDIF
		| IF P_A condicion P_C programa ELSE programa ENDIF
		;

condicion: comparacion
         | condicion AND comparacion 
		 | condicion OR comparacion
		 ;

comparacion: expresion MENOR expresion { printf("Condicion menor OK\n"); }
		   | expresion MENOR_IGUAL expresion { printf("Condicion menor o igual OK\n"); }
		   | expresion MAYOR expresion { printf("Condicion mayor OK\n"); }
		   | expresion MAYOR_IGUAL expresion { printf("Condicion mayor o igual OK\n"); }
		   | expresion IGUAL expresion { printf("Condicion igual OK\n"); }
		   | expresion DISTINTO expresion { printf("Condicion distinto OK\n"); }
		   | inlist { printf("INLIST OK\n"); }
		   ; 

average: AVG P_A C_A avg_expresiones C_C P_C

avg_expresiones: expresion
			   | expresion COMA avg_expresiones
			   ;

inlist: INLIST P_A ID COMA C_A inlist_expresiones C_C P_C
	  ;

inlist_expresiones: expresion
		          | inlist_expresiones PUNTO_COMA expresion
		          ;
		  
expresion: expresion OP_SUMA termino { printf("Suma OK\n"); }
		 | expresion OP_RESTA termino { printf("Resta OK\n"); }
		 | termino
		 ;
		 
termino: termino OP_MULT factor { printf("Multiplicacion OK\n"); }
	   | termino OP_DIV factor	{ printf("Division OK\n"); }
	   | factor
	   ;
	   
factor: ID	{ printf("ID es: %s\n",yylval.strVal); }  
	  | constante
	  | P_A expresion P_C
	  ;
	  
constante: CTE_INT { yylval.intVal = atoi(yylval.strVal); validarInt(yylval.intVal); printf("ENTERO es: %d\n",yylval.intVal); }  
         | CTE_STRING { printf("STRING es: %s\n",yylval.strVal); validarString(yylval.strVal); }  
		 | CTE_REAL { yylval.realVal = atof(yylval.strVal); validarReal(yylval.realVal); printf("REAL es: %.2f\n",yylval.realVal); }
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
	yyparse();
  }
  fclose(yyin);
  return 0;
}

int yyerror(void)
{
	printf ("Syntax Error\n");
	system ("Pause");
	exit (1);
}

/* 
	Funcion para validar el rango de enteros 
*/
int validarInt(int entero)
{

	if(entero < INT_MIN || entero > INT_MAX){
		printf(" ERROR: Entero fuera de rango (32 bits maximo)\n");
		yyerror();
	}
	return 1;
}

/*
	Funcion para validar string 
*/
int validarString(char *str)
{
	char *aux = str;
    int largo = strlen(aux);
 
	if(largo > 30){
		printf(" ERROR: Cadena demasiado larga (30 caracteres maximo)\n");
		yyerror();
	}else{
		//printf(" Valide bien la cadena! : %s\n", str);
	}
	
	return 1;
}

/*
	Funcion para validar float 
*/
int validarReal(float Real)
{

	if(Real < FLT_MIN || Real > FLT_MAX){
		printf(" ERROR: Real fuera de rango (-1.17549e-38; 3.40282e38) \n");
		yyerror();
	}else{
		//printf("Valide bien float ! \n");
	}
	return 1;
}


