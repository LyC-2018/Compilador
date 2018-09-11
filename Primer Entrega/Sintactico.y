%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE *yyin;
char *yytext;
extern int yylineno;

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
%token AND OR
%token INT FLOAT STRING 
%token DECVAR ENDDEC
%%

start: programa { printf("\n\n\tCOMPILACION EXITOSA!!\n\n\n"); }
	 ;

programa: declaracion { printf("Declaracion OK\n"); } bloque
        | bloque
		;
		
bloque: sentencia
	  | bloque sentencia
	  ;
		
sentencia: asignacion { printf("Asignacion OK\n"); }
		 | iteracion { printf("Iteracion OK\n"); }
		 | decision { printf("Seleccion OK\n"); }
		 ;
		 
asignacion: ID ASIG expresion
		  ;

iteracion: WHILE P_A condicion P_C programa ENDWHILE
		 ;
		
decision: IF P_A condicion P_C programa ENDIF
		| IF P_A condicion P_C programa ELSE programa ENDIF
		;

declaracion: DECVAR listaVar ENDDEC
		   | DECVAR ENDDEC
		   ;
		   
listaVar: variables
        | listaVar variables
		;

variables: ID DOS_PUNTOS tipo
		 | ID COMA variables
		 ;
	
tipo: INT
    | FLOAT
	| STRING
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
	  | average { printf("AVG OK\n"); }
	  ;
	  
constante: CTE_INT { printf("ENTERO es: %d\n",yylval.intVal); }  
         | CTE_STRING { printf("STRING es: %s\n",yylval.strVal); }  
		 | CTE_REAL { printf("REAL es: %.2f\n",yylval.realVal); }
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

int yyerror(char *errMessage)
{
   printf("(!) ERROR en la linea %d: %s\n",yylineno,errMessage);
   fprintf(stderr, "Fin de ejecucion.\n");
   system ("Pause");
   exit (1);
}


