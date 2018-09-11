%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <float.h>
#include <limits.h>
#include "y.tab.h"

FILE *yyin;

/* FUNCIONES */
int validarInt(int entero);
int validarString(char *str);
int validarReal(float flotante);
int validarID(char *str);
void mensaje_error();

%}

%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
DELIM           [ \t\n]
CARACTER        [a-z|A-Z|0-9|=|>|<|!|:|+|-|*|/|?|¿|!|¡|@|%|#|&|°|´|^|`|~|/|\|-|_|.|,|;||]
CTE_STRING      \"({CARACTER}+|{DELIM})*\"
CTE_REAL        {DIGITO}+"."{DIGITO}*
CTE_INT         {DIGITO}+
ID				{LETRA}({LETRA}|{DIGITO}|_)*
INLIST          [Ii][Nn][Ll][Ii][Ss][Tt]
AVG				[Aa][Vv][Gg]
WHILE           [Ww][Hh][Ii][Ll][Ee]
ENDWHILE        [Ee][Nn][Dd][Ww][Hh][Ii][Ll][Ee]
IF				[Ii][Ff]
ELSE			[Ee][Ll][Ss][Ee]
ENDIF			[Ee][Nn][Dd][Ii][Ff]
AND				[Aa][Nn][Dd]
OR				[Oo][Rr]
INT				[Ii][Nn][Tt]
FLOAT			[Ff][Ll][Oo][Aa][Tt]
STRING			[Ss][Tt][Rr][Ii][Nn][Gg]
DECVAR			[Dd][Ee][Cc][Vv][Aa][Rr]
ENDDEC			[Ee][Nn][Dd][Dd][Ee][Cc]
READ			[Rr][Ee][Aa][Dd]
WRITE			[Ww][Rr][Ii][Tt][Ee]

%%
"+"				{ return OP_SUMA; }
"-"				{ return OP_RESTA; }
"*"				{ return OP_MULT; }
"/"				{ return OP_DIV; }
"="			    { return ASIG; }
"("				{ return P_A; }
")"				{ return P_C; }
"["             { return C_A; }
"]"             { return C_C; }
";"             { return PUNTO_COMA; }
","             { return COMA; }
":"				{ return DOS_PUNTOS; }
{INLIST}        { return INLIST; }
{AVG}			{ return AVG; }
{WHILE}         { return WHILE; } 
{ENDWHILE}      { return ENDWHILE; }
{IF}			{ return IF; }
{ELSE}			{ return ELSE; }
{ENDIF}			{ return ENDIF; }
{AND}			{ return AND; }
{OR}			{ return OR; }

">"             { return MAYOR; }
">="            { return MAYOR_IGUAL; }
"<"             { return MENOR; }
"<="            { return MENOR_IGUAL; }
"=="            { return IGUAL; }
"!="            { return DISTINTO; }

{ID}			{ yylval.strVal = strdup(yytext); validarID(yylval.strVal); return ID; }
{CTE_STRING}	{ yylval.strVal = strdup(yytext); validarString(yylval.strVal); return CTE_STRING; }
{CTE_INT}		{ yylval.intVal = atoi(yytext); validarInt(yylval.intVal); return CTE_INT; }
{CTE_REAL}		{ yylval.realVal = atof(yytext); validarReal(yylval.realVal); return CTE_REAL; }

{INT}			{ return INT; }
{FLOAT}			{ return FLOAT; }
{STRING}		{ return STRING; }
{DECVAR}		{ return DECVAR; }
{ENDDEC}		{ return ENDDEC; }

{READ}          { return READ; }
{WRITE}         { return WRITE; }

" "
"\t"
"\n"		    
%%

/* 
	Funcion para validar el rango de enteros 
*/
int validarInt(int entero)
{

	if(entero < INT_MIN || entero > INT_MAX){
		printf("(!) ERROR: Constante entera fuera de rango (32 bits maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}
	return 1;
}

/*
	Funcion para validar string 
*/
int validarString(char *str)
{
	if(strlen(str) > 30){
		printf("(!) ERROR: Constante string fuera de rango (30 caracteres maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}else{
		//printf(" Valide bien la cadena! : %s\n", str);
	}
	
	return 1;
}

/*
	Funcion para validar float 
*/
int validarReal(float real)
{

	if(real < FLT_MIN || real > FLT_MAX){
		printf("(!) ERROR: Constante real fuera de rango (-1.17549e-38; 3.40282e38) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}else{
		//printf("Valide bien float ! \n");
	}
	return 1;
}

/*
	Funcion para validar identificador
*/
int validarID(char *str)
{
    int largo = strlen(str);
 
	if(largo > 10){
		printf("(!) ERROR: Identificador fuera de rango (10 caracteres maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}else{
		//printf(" Valide bien el identificador! : %s\n", str);
	}
	
	return 1;
}

