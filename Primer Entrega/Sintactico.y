%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"

FILE *yyin;
char *yytext;
%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <strVal>CTE_STRING <realVal>CTE_REAL
%token ASIG OP_SUMA OP_RESTA OP_MULT OP_DIV
%token MENOR MAYOR IGUAL DISTINTO MENOR_IGUAL MAYOR_IGUAL
%token WHILE ENDWHILE
%token IF ELSE ENDIF
%token P_A P_C
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
		   ; 
		  
expresion: expresion OP_SUMA termino { printf("Suma OK\n"); }
		 | expresion OP_RESTA termino { printf("Resta OK\n"); }
		 | termino
		 ;
		 
termino: termino OP_MULT factor { printf("Multiplicacion OK\n"); }
	   | termino OP_DIV factor	{ printf("Division OK\n"); }
	   | factor
	   ;
	   
factor: ID
	  | constante
	  | P_A expresion P_C
	  ;
	  
constante: CTE_INT { yylval.intVal = atoi(yylval.strVal); printf("ENTERO es: %d\n",yylval.intVal); }  
         | CTE_STRING { printf("STRING es: %s\n",yylval.strVal); }  
		 | CTE_REAL { yylval.realVal = atof(yylval.strVal); printf("REAL es: %.2f\n",yylval.realVal); }
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


