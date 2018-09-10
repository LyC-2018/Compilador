%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE *yyin;

%}

%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
ESPACIO         [ ]
CARACTER        [a-z|A-Z|0-9|=|>|<|!|:|+|-|*|/|?|¿|!|¡|@|%|#|&|°|´|^|`|~|/|\|-|_|.|,|;||]
CTE_STRING      \"({CARACTER}+|{ESPACIO})*\"
CTE_REAL        {DIGITO}+"."{DIGITO}*
CTE_INT         {DIGITO}+
ID				{LETRA}({LETRA}|{DIGITO}|_)*
WHILE           [Ww][Hh][Ii][Ll][Ee]
ENDWHILE        [Ee][Nn][Dd][Ww][Hh][Ii][Ll][Ee]
IF				[Ii][Ff]
ELSE			[Ee][Ll][Ss][Ee]
ENDIF			[Ee][Nn][Dd][Ii][Ff]
AND				[Aa][Nn][Dd]
OR				[Oo][Rr]
DOS_PUNTOS		:
COMA			,
INT				[Ii][Nn][Tt]
FLOAT			[Ff][Ll][Oo][Aa][Tt]
STRING			[Ss][Tt][Rr][Ii][Nn][Gg]
DECVAR			[Dd][Ee][Cc][Vv][Aa][Rr]
ENDEC			[Ee][Nn][Dd][Ee][Cc]
%%

"+"				{ return OP_SUMA; }
"-"				{ return OP_RESTA; }
"*"				{ return OP_MULT; }
"/"				{ return OP_DIV; }
"="			    { return ASIG; }
"("				{ return P_A; }
")"				{ return P_C; }
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

{ID}			{ yylval.strVal = strdup(yytext); return ID; }
{CTE_STRING}	{ yylval.strVal = strdup(yytext); return CTE_STRING; }
{CTE_INT}		{ yylval.strVal = strdup(yytext); return CTE_INT; }
{CTE_REAL}		{ yylval.strVal = strdup(yytext); return CTE_REAL; }

{INT}			{ return INT; }
{FLOAT}			{ return FLOAT; }
{STRING}		{ return STRING; }
{DECVAR}		{ return DECVAR; }
{ENDEC}			{ return ENDEC; }
":"				{ return DOS_PUNTOS; }
","				{ return COMA; }
"\n"
"\t"

