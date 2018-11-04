#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

void genera_asm();
void generaSegmDatosAsm(FILE*);
char* getCodOp(char*);

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

