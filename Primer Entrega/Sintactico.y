%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"

int yylval;
FILE *yyin;
char *yytext;
%}

%token ID CTE CADENA
%token ASIG OP_SUMA OP_RESTA OP_MULT OP_DIV
%token P_A P_C

%%
programa: sentencia { printf("\n\n\tCOMPILACION EXITOSA!!\n\n\n"); }
		| programa sentencia
		;
		
sentencia: asignacion { printf("Asignacion OK\n"); }
		 ;
		 
asignacion: ID ASIG expresion
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
	   | CTE {$1 = yylval ;printf("ENTERO es: %d\n", yylval);}
	   | P_A expresion P_C
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


