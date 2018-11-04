#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int pila_asm[50];
int tope_pila_asm = 0;

void genera_asm();
void generaSegmDatosAsm(FILE*);
char* getCodOp(char*);
void getSaltoInverso(char*);
char* truncar(int);

/************************************************************************************************************/

void genera_asm()
{
	int cont=0;
	char* file_asm = "Final.asm";
	int op1, op2, aux_op1, aux_op2, esPrimeraCondicion=0, esAnd=0, functionIndex;
	char aux[10], cod_op[5], aux_nexo[3], etiqueta_aux[20], varRetorno[257];
	FILE* pf_asm;
	nodo_polaca* act = tope;
	nodo_polaca* temporal;
	int cant_aux = 1, cant_etiq_aux = 0, invertir = 0;

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

	 /*generamos el segmento de codigo*/
	while(act)
	{
	    //printf("act->infTS:%d,act->Token:%s,act->tipo:%d\n",act->ind_TS,act->token,act->tipo);
		if(act->tipo == 0)
		{
			/*una etiqueta, directamente la escribo en el asm, no la apilo*/
			fprintf(pf_asm, "%s: \n", act->token);
		}
		else if(act->tipo < 0)
		{
				/*operando, apilo*/
				pila_asm[tope_pila_asm++] = act->ind_TS;
		}
		else if(act->tipo > 0)
		{
		    /**SALTO FALSO**/
			/*operador, desapilo y opero*/
			if(!strcmp(act->token, "BF"))
			{
				/*si es BF salgo*/
				act = act->sig;
				continue;
			}

			if(!strcmp(act->token, "GET")||!strcmp(act->token, "PUT")  || !strcmp(act->token, "JMP")
                ||!strcmp(act->token, "TRUNC")||!strcmp(act->token, "ROUND"))
			{
				/* saco un solo operando*/
				op1 = pila_asm[--tope_pila_asm];
			}
			else
			{
			    //printf("Pila[%d]:%d\n",tope_pila_asm-1,pila_asm[tope_pila_asm-1]);
				op1 = pila_asm[--tope_pila_asm];
				//printf("Pila[%d]:%d\n",tope_pila_asm-1,pila_asm[tope_pila_asm-1]);
				op2 = pila_asm[--tope_pila_asm];
				//printf("Pila[%d]:%d\n",tope_pila_asm-1,pila_asm[tope_pila_asm-1]);
			}

			/*escribimos operacion en assembler*/
			/**ASIGNACION**/
			if(!strcmp(act->token, ":="))
			{
				/*caso especial*/
				if(!strcmp(getTipo(op2), "CTE_INT")||!strcmp(getTipo(op2), "CTE_REAL")||!strcmp(getTipo(op2), "CONSNUMBER")||
				!strcmp(getTipo(op2), "REAL")||!strcmp(getTipo(op2), "INT"))
				{
				    /*verifico el valor, si no es vacio. NO se hace la asignacion de la constante*/
				    if(!strcmp(getTipo(op2), "CONSNUMBER") && strcmp(getValor(op2), getValor(op1)))
                    {
                        printf("No es posible realizar la asignacion a la variable CONST: %s[%s]\n",getNombre(op2),getValor(op2));
                    }
                    else
                    {
                        fprintf(pf_asm, "\t FLD %s \t;Cargo valor \n", getNombreAsm(op1));
                        if(!strcmp(getTipo(op2), "INT")){
                            fprintf(pf_asm, "\t FRNDINT\t;Redondeo el valor para almacenar un entero\n");
                        }
                        fprintf(pf_asm, "\t FSTP %s \t; Se lo asigno a la variable que va a guardar el resultado \n", getNombreAsm(op2));
                    }
				}
				else if(!strcmp(getTipo(op2), "CTE_STRING")||!strcmp(getTipo(op2), "CONSSTRING")||!strcmp(getTipo(op2), "STR"))
                {
                    /*verifico el valor, si no es vacio. NO se hace la asignacion de la constante*/
				    if(!strcmp(getTipo(op2), "CONSSTRING") && strcmp(getValor(op2), getValor(op1)))
                    {
                        printf("No es posible realizar la asignacion a la variable CONST: %s[%s]\n",getNombre(op2),getValor(op2));
                    }
                    else
                    {
                        fprintf(pf_asm, "\t mov si,OFFSET %s \t;Cargo en si el origen\n", getNombreAsm(op1));
                        fprintf(pf_asm, "\t mov di,OFFSET %s \t; cargo en di el destino \n", getNombreAsm(op2));
                        fprintf(pf_asm, "\t STRCPY\t; llamo a la macro para copiar \n");
                    }
				}
				/*printf("Operador %s", act->token);
				printf(" OP1: %d/%s", op1, getNombreAsm(op1));
				printf(" OP2: %d/%s\n" , op2, getNombreAsm(op2));
                */
			}
			/**SALIDAS**/
			else if(!strcmp(act->token, "PUT"))
			{
				/*caso especial*/
				if(!strcmp(getTipo(op1), "CONSNUMBER")
					|| !strcmp(getTipo(op1), "CTE_REAL")||!strcmp(getTipo(op1), "REAL"))
				{
					fprintf(pf_asm, "\t DisplayFloat %s,2 \n", getNombreAsm(op1));
					fprintf(pf_asm, "\t MOV AX, SEG _NEWLINE \n");
	  	 			fprintf(pf_asm, "\t MOV DS, AX \n");
					fprintf(pf_asm, "\t mov DX, OFFSET _NEWLINE;salto de linea \n");
					fprintf(pf_asm, "\t mov ah, 9 \n");
					fprintf(pf_asm, "\t int 21h \n");
				}else if(!strcmp(getTipo(op1), "CTE_INT")|| !strcmp(getTipo(op1), "INT"))
					{

					fprintf(pf_asm, "\t DisplayFloat %s,2 \n", getNombreAsm(op1));
					fprintf(pf_asm, "\t MOV AX, SEG _NEWLINE \n");
	  	 			fprintf(pf_asm, "\t MOV DS, AX \n");
					fprintf(pf_asm, "\t mov DX, OFFSET _NEWLINE;salto de linea \n");
					fprintf(pf_asm, "\t mov ah, 9 \n");
					fprintf(pf_asm, "\t int 21h \n");
					}

				else if(!strcmp(getTipo(op1), "CTE_STRING")||!strcmp(getTipo(op1), "CONSSTRING")
                        ||!strcmp(getTipo(op1), "STR")){
					fprintf(pf_asm, "\t MOV AX, SEG %s \n", getNombreAsm(op1));
	  	 			fprintf(pf_asm, "\t MOV DS, AX \n");
					fprintf(pf_asm, "\t mov DX, OFFSET %s \n", getNombreAsm(op1));
					fprintf(pf_asm, "\t mov ah, 9 \n");
					fprintf(pf_asm, "\t int 21h \n");
					fprintf(pf_asm, "\t MOV AX, SEG _NEWLINE \n");
	  	 			fprintf(pf_asm, "\t MOV DS, AX \n");
					fprintf(pf_asm, "\t mov DX, OFFSET _NEWLINE;salto de linea \n");
					fprintf(pf_asm, "\t mov ah, 9 \n");
					fprintf(pf_asm, "\t int 21h \n");
				}
			}
			/**ENTRADAS**/
			else if(!strcmp(act->token, "GET"))
			{
				/*caso especial*/
				if(!strcmp(getTipo(op1), "REAL"))
				{
					fprintf(pf_asm, "\t GetFloat %s\n", getNombreAsm(op1));
				}else if (!strcmp(getTipo(op1), "INT")){
					fprintf(pf_asm, "\t GetFloat %s\n", getNombreAsm(op1));
				} else
				{
					fprintf(pf_asm, "\t GetString %s\n", getNombreAsm(op1));
				}
			}

			/**ROUND**/
			else if(!strcmp(act->token, "ROUND"))
			{
				int indexAux;
				sprintf(aux, "_aux%d", cant_aux++);
				/*insertamos variables auxiliares en TS si no estan */
				indexAux = insertarEnTS(aux, "REAL", "", "");
				fprintf(pf_asm, "\t FLD %s \t;Cargo operando 1\n", getNombreAsm(op1));
				fprintf(pf_asm, "\t FRNDINT\t;Redondeo el valor para almacenar un entero\n");
				fprintf(pf_asm, "\t FSTP %s \t;Almaceno el resultado en una var auxiliar\n", getNombreAsm(indexAux));

				pila_asm[tope_pila_asm++] = indexAux;
			}
			/**TRUNC**/
			else if(!strcmp(act->token, "TRUNC"))
			{
				int indexAux;
				sprintf(aux, "_aux%d", cant_aux++);
				/*insertamos variables auxiliares en TS si no estan */
				indexAux = insertarEnTS(aux, "REAL", "", "");
				fprintf(pf_asm, "\t FLD %s \t;Cargo operando 1\n", getNombreAsm(op1));
				fprintf(pf_asm, "\t CALL FTOI \t;convierto a int 1\n");
				fprintf(pf_asm, "\t FSTP %s \t;Almaceno el resultado en una var auxiliar\n", getNombreAsm(indexAux));

				pila_asm[tope_pila_asm++] = indexAux;
			}

			/**SALTO INCONDICIONAL**/
			else if(!strcmp(act->token, "JMP"))
			{
				/*caso especial*/
				fprintf(pf_asm, "\t JMP %s \n", getNombre(op1));
			}

			/**OPERACIONES**/
			else
			{
				strcpy(cod_op, getCodOp(act->token));

				if(!strcmp(act->token, "==") || !strcmp(act->token, "!=") || !strcmp(act->token, "<")
					|| !strcmp(act->token, "<=") || !strcmp(act->token, ">") || !strcmp(act->token, ">="))
				{
					/* condiciones, sacamos un operando mas que es la etiqueta */
					temporal=act->sig;

					if(!strcmp(temporal->token, "!"))
					{
						/*caso especial donde invierto el salto*/
						getSaltoInverso(cod_op);
						/*me muevo ahora si a la etiqueta de salto*/
						act = act->sig;
						temporal=temporal->sig;
					}

					if(!strstr(getNombre(temporal->ind_TS), "_ETIQ"))
					{
						/*no vino una etcontinueiqueta sino que es una condicion compuesta, sacamos todo hasta la etiqueta de salto para generar la expresion*/
						temporal = temporal->sig;
						while(!strstr(getNombre(temporal->ind_TS), "_ETIQ")){
							if(!strcmp(temporal->token, "&&"))
							{
								esAnd=1;
							}
							temporal = temporal->sig;
						}
						if(esPrimeraCondicion==0){
							/*PRIMERA CONDICION*/
							if(esAnd==1){
								/*PRIMERA CONDICION DEL AND*/
								fprintf(pf_asm, "\t FNINIT \n");;
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op1));
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op2));
								fprintf(pf_asm, "\t FCOMP \n");
								fprintf(pf_asm, "\t FFREE ST(0) \n");
								fprintf(pf_asm, "\t FSTSW AX \n");
								fprintf(pf_asm, "\t SAHF \n");
								fprintf(pf_asm, "\t %s %s \n", cod_op, getNombre(temporal->ind_TS));
							}else{
								/*PRIMERA CONDICION DEL OR*/
								/*CREO UNA ETIQUETA AUXILIAR PARA SALTAR AL TRUE SI ESTO ES VERDADERO*/
								sprintf(etiqueta_aux, "_ETIQ_AUX%d", cant_etiq_aux++);
								getSaltoInverso(cod_op);
								fprintf(pf_asm, "\t FNINIT \n");
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op1));
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op2));
								fprintf(pf_asm, "\t FCOMP \n");
								fprintf(pf_asm, "\t FFREE ST(0) \n");
								fprintf(pf_asm, "\t FSTSW AX \n");
								fprintf(pf_asm, "\t SAHF \n");
								fprintf(pf_asm, "\t %s %s \n", cod_op, etiqueta_aux);
							}
							esPrimeraCondicion=1;
						}else{
							act=temporal;
							if(esAnd==1){
								/*SEGUNDA CONDICION DEL AND*/
								/*SOLO SE VA A EJECUTAR ESTO SI LA PRIMER PARTE FUE TRUE*/
								fprintf(pf_asm, "\t FNINIT \n");
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op1));
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op2));
								fprintf(pf_asm, "\t FCOMP \n");
								fprintf(pf_asm, "\t FFREE ST(0) \n");
								fprintf(pf_asm, "\t FSTSW AX \n");
								fprintf(pf_asm, "\t SAHF \n");
								fprintf(pf_asm, "\t %s %s \n", cod_op, getNombre(act->ind_TS));
							}else{
								/*SEGUNDA CONDICION DEL OR*/
								/*SOLO SE VA A EJECUTAR ESTO SI LA PRIMER PARTE FUE FALSE*/
								fprintf(pf_asm, "\t FNINIT \n");
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op1));
								fprintf(pf_asm, "\t FLD %s \n", getNombreAsm(op2));
								fprintf(pf_asm, "\t FCOMP \n");
								fprintf(pf_asm, "\t FFREE ST(0) \n");
								fprintf(pf_asm, "\t FSTSW AX \n");
								fprintf(pf_asm, "\t SAHF \n");
								fprintf(pf_asm, "\t %s %s \n", cod_op, getNombre(act->ind_TS));
								/*PEGO ETIQUETA AUXILIAR*/
								fprintf(pf_asm, "%s: \n", etiqueta_aux);
							}
							esAnd=0;
							esPrimeraCondicion=0;
						}
					}
					else
					{
						act=temporal;
						/*condicion simple*/
						fprintf(pf_asm, "\t FNINIT \n");
						fprintf(pf_asm, "\t FLD %s\t\t;Cargo Operando1 \n", getNombreAsm(op1));
						fprintf(pf_asm, "\t FLD %s\t\t;Cargo Operando2 \n", getNombreAsm(op2));
						fprintf(pf_asm, "\t FCOMP\t\t;Comparo \n");
						fprintf(pf_asm, "\t FFREE ST(0) \t; Vacio ST0\n");
						fprintf(pf_asm, "\t FSTSW AX \t\t; mueve los bits C a FLAGS\n");
						fprintf(pf_asm, "\t SAHF \t\t\t;Almacena el registro AH en el registro FLAGS \n");
						fprintf(pf_asm, "\t %s %s \t;Si cumple la condicion salto a la etiqueta\n", cod_op, getNombre(act->ind_TS));
					}
				}
				else
				{
				    //printf("Hasta Aca llego\n");
					if(!strcmp(getTipo(op1), "CTE_INT")||!strcmp(getTipo(op1), "CONSNUMBER") //VERRRRR
						||!strcmp(getTipo(op1), "CTE_REAL")||!strcmp(getTipo(op1), "REAL")
						||!strcmp(getTipo(op1), "INT")
						||!strcmp(getTipo(op2), "CTE_INT")||!strcmp(getTipo(op2), "CONSNUMBER")
						||!strcmp(getTipo(op2), "CTE_REAL")||!strcmp(getTipo(op2), "REAL")
						||!strcmp(getTipo(op2), "INT"))
					{
					  	int indexAux;
						sprintf(aux, "_aux%d", cant_aux++);
						/*insertamos variables auxiliares en TS si no estan */
						indexAux = insertarEnTS(aux, "REAL", "", "");
						fflush(pf_asm);
						fprintf(pf_asm, "\t FLD %s \t;Cargo operando 1\n", getNombreAsm(op1));
						fprintf(pf_asm, "\t FLD %s \t;Cargo operando 2\n", getNombreAsm(op2));
						fflush(pf_asm);
						/*
						printf("Operador %s", act->token);
						fflush(pf_asm);
						printf(" OP1: %d/%s", op1, getNombreAsm(op1));
						printf(" OP2: %d/%s\n" , op2, getNombreAsm(op2));
						*/
						/*caso especial que no son comutativos, debo intercambiar operadores para que queden bien*/
						if(!strcmp(act->token, "-") || !strcmp(act->token, "/"))
						{
							fprintf(pf_asm, "\t FXCH \t;Como es una operacion no conmutativa invierto los operandos\n");
						}

						fprintf(pf_asm, "\t %s \t\t;Opero\n", cod_op);
						fprintf(pf_asm, "\t FSTP %s \t;Almaceno el resultado en una var auxiliar\n", getNombreAsm(indexAux));

						pila_asm[tope_pila_asm++] = indexAux;
					}else{
						int indexAux;

						sprintf(aux, "_aux%d", cant_aux++);
						/*insertamos variables auxiliares en TS si no estan */
						indexAux = insertarEnTS(aux, "STR", "", "");

						fflush(pf_asm);
						fprintf(pf_asm, "\t mov si,OFFSET %s \t;Cargo en si el origen\n", getNombreAsm(op2));
						fprintf(pf_asm, "\t mov di,OFFSET %s \t; cargo en di el destino \n", getNombreAsm(indexAux));
						fprintf(pf_asm, "\t STRCPY\t; llamo a la macro para copiar \n");
						fprintf(pf_asm, "\t mov si,OFFSET %s \t;Cargo en si el origen\n", getNombreAsm(op1));
						fprintf(pf_asm, "\t mov di,OFFSET %s \t; cargo en di el destino \n", getNombreAsm(indexAux));
						fprintf(pf_asm, "\t STRCAT\t; llamo a la macro para copiar \n");
                        /*
						printf("Operador %s", act->token);
						printf(" OP1: %d/%s", op1, getNombreAsm(op1));
						printf(" OP2: %d/%s\n" , op2, getNombreAsm(op2));
                        */
						pila_asm[tope_pila_asm++] = indexAux;
					}
				}
			}
		}

		act = act->sig;
		//printf("Pila[%d]:%d\n",tope_pila_asm-1,pila_asm[tope_pila_asm-1]);
		//fflush(pf_asm);
	}

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
	for(i=0; i<getCountTS(); i++)
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
		}
}

/************************************************************************************************************/
char* getCodOp(char* token)
{
	if(!strcmp(token, "+"))
	{
		return "FADD";
	}
	else if(!strcmp(token, ":="))
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
	else if(!strcmp(token, "=="))
	{
		return "JNE";
	}
	else if(!strcmp(token, "!="))
	{
		return "JE";
	}
	else if(!strcmp(token, "<"))
	{
		return "JAE";
	}
	else if(!strcmp(token, "<="))
	{
		return "JA";
	}
	else if(!strcmp(token, ">"))
	{
		return "JBE";
	}
	else if(!strcmp(token, ">="))
	{
		return "JB";
	}
	if(!strcmp(token, "++"))
	{
		return "STCT";
	}
}

/************************************************************************************************************/
void getSaltoInverso(char* salto)
{
	if(!strcmp(salto, "JNE"))
	{
		memset(salto, '\0', sizeof(salto));
		strcpy(salto, "JE");
	}
	else if(!strcmp(salto, "JE"))
	{
		memset(salto, '\0', sizeof(salto));
		strcpy(salto, "JNE");
	}
	else if(!strcmp(salto, "JBE"))
	{
		memset(salto, '\0', sizeof(salto));
		strcpy(salto, "JA");
	}
	else if(!strcmp(salto, "JB"))
	{
		memset(salto, '\0', sizeof(salto));
		strcpy(salto, "JAE");
	}
	else if(!strcmp(salto, "JAE"))
	{
		memset(salto, '\0', sizeof(salto));
		strcpy(salto, "JB");
	}
	else if(!strcmp(salto, "JA"))
	{
		memset(salto, '\0', sizeof(salto));
		strcpy(salto, "JBE");
	}
}

/********************************************************************************************************/

char* truncar(int op1)
{
   char aux[31];
   char aux1[31];
   char aux2[31];
/*
    strcpy(aux,getValor(op1));
    aa=aux;


   while(aa){
        printf("aux %s y getvalor: %s\n",aux,getValor(op1));
    if(*aa=='.')
    {
        *aa='\0';
        return aa;
    }
    else
        aa++;
   }

*/
    sscanf(getValor(op1),"%[^.].%s",aux, aux1);
    sprintf(aux2,"%s.0",aux);
    return aux2;
}
