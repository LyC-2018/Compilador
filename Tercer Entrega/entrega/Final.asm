include macros2.asm
include number.asm
.MODEL	LARGE 
.386
.STACK 200h 
.CODE 
MAIN:


	 MOV AX,@DATA 	;inicializa el segmento de datos
	 MOV DS,AX 
	 MOV ES,AX 
	 FNINIT 

	 FLD @_5 	;Cargo operando 1
	 FLD @_8 	;Cargo operando 2
	 FMUL 		;Opero
	 FSTP @_aux2 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux2 	;Cargo valor 
	 FSTP @a 	; Se lo asigno a la variable que va a guardar el resultado 
	 DisplayFloat @a,2 
	 newLine 
	 FLD @_2_3 	;Cargo valor 
	 FSTP @c 	; Se lo asigno a la variable que va a guardar el resultado 
ETIQ_10: 
	 FLD @c 	;Cargo operando 1
	 FLD @_2_3 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux12 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux12 	;Cargo operando 1
	 FLD @_2 	;Cargo operando 2
	 FDIV 		;Opero
	 FSTP @_aux14 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux14		;comparacion, operando1 
	 FLD @_2_3		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JNE ETIQ_19 	;Si cumple la condicion salto a la etiqueta
	 JMP ETIQ_23 	;Si cumple la condicion salto a la etiqueta
ETIQ_19: 
	 FLD @a		;comparacion, operando1 
	 FLD @_40		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JNE ETIQ_34 	;Si cumple la condicion salto a la etiqueta
ETIQ_23: 
	 FLD @c 	;Cargo operando 1
	 FLD @_0_1 	;Cargo operando 2
	 FSUB 		;Opero
	 FSTP @_aux25 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux25 	;Cargo valor 
	 FSTP @c 	; Se lo asigno a la variable que va a guardar el resultado 
	 DisplayFloat @c,2 
	 newLine 
	 FLD @_3 	;Cargo valor 
	 FSTP @a 	; Se lo asigno a la variable que va a guardar el resultado 
	 JMP ETIQ_10 	;Si cumple la condicion salto a la etiqueta
ETIQ_34: 
	 FLD @_2 	;Cargo operando 1
	 FLD @_1 	;Cargo operando 2
	 FMUL 		;Opero
	 FSTP @_aux36 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux36 	;Cargo operando 1
	 FLD @_1 	;Cargo operando 2
	 FSUB 		;Opero
	 FSTP @_aux38 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux38		;comparacion, operando1 
	 FLD @_1		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JNE ETIQ_53 	;Si cumple la condicion salto a la etiqueta
	 FLD @a 	;Cargo operando 1
	 FLD @b 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux45 	;Almaceno el resultado en una var auxiliar
	 FLD @_2 	;Cargo operando 1
	 FLD @_aux45 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux46 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux46 	;Cargo operando 1
	 FLD @c 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux48 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux48 	;Cargo operando 1
	 FLD @_3 	;Cargo operando 2
	 FDIV 		;Opero
	 FSTP @_aux50 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux50 	;Cargo valor 
	 FSTP @c 	; Se lo asigno a la variable que va a guardar el resultado 
ETIQ_53: 
	 DisplayString @__Resultado_AVG_ 
	 newLine 
	 DisplayFloat @c,2 
	 newLine 
ETIQ_57: 
	 FLD @_2 	;Cargo operando 1
	 FLD @b 	;Cargo operando 2
	 FMUL 		;Opero
	 FSTP @_aux60 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux60 	;Cargo operando 1
	 FLD @_7 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux62 	;Almaceno el resultado en una var auxiliar
	 FLD @a		;comparacion, operando1 
	 FLD @_aux62		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JE ETIQ_79 	;Si cumple la condicion salto a la etiqueta
	 FLD @a		;comparacion, operando1 
	 FLD @_12		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JE ETIQ_79 	;Si cumple la condicion salto a la etiqueta
	 FLD @b 	;Cargo operando 1
	 FLD @_34 	;Cargo operando 2
	 FMUL 		;Opero
	 FSTP @_aux71 	;Almaceno el resultado en una var auxiliar
	 FLD @a 	;Cargo operando 1
	 FLD @_aux71 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux72 	;Almaceno el resultado en una var auxiliar
	 FLD @a		;comparacion, operando1 
	 FLD @_aux72		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JE ETIQ_79 	;Si cumple la condicion salto a la etiqueta
	 FLD @a		;comparacion, operando1 
	 FLD @_40		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JE ETIQ_79 	;Si cumple la condicion salto a la etiqueta
	 JMP ETIQ_96 	;Si cumple la condicion salto a la etiqueta
ETIQ_79: 
	 FLD @b		;comparacion, operando1 
	 FLD @_1		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JNE ETIQ_96 	;Si cumple la condicion salto a la etiqueta
	 FLD @_1 	;Cargo valor 
	 FSTP @a 	; Se lo asigno a la variable que va a guardar el resultado 
	 FLD @z		;comparacion, operando1 
	 FLD @_10		;comparacion, operando2 
	 FCOMP		;Comparo 
	 FFREE ST(0) 	; Vacio ST0
	 FSTSW AX 		; mueve los bits C a FLAGS
	 SAHF 			;Almacena el registro AH en el registro FLAGS 
	 JNE ETIQ_95 	;Si cumple la condicion salto a la etiqueta
	 FLD @a 	;Cargo operando 1
	 FLD @_1 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux92 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux92 	;Cargo valor 
	 FSTP @a 	; Se lo asigno a la variable que va a guardar el resultado 
ETIQ_95: 
	 JMP ETIQ_57 	;Si cumple la condicion salto a la etiqueta
ETIQ_96: 
	 mov si,OFFSET @__Hola_ 	;Cargo en si el origen
	 mov di,OFFSET @E 	; cargo en di el destino 
	 STRCPY	; llamo a la macro para copiar 
	 mov si,OFFSET @E 	;Cargo operando1
	 mov di,OFFSET @__Holaa____Mundo_ 	; cargo operando2 
	 STRCMP	; llamo a la macro para comparar 
	 JE ETIQ_111 	;Si cumple la condicion salto a la etiqueta
	 mov si,OFFSET @D 	;Cargo en si el origen
	 mov di,OFFSET @E 	; cargo en di el destino 
	 STRCPY	; llamo a la macro para copiar 
	 DisplayString @__Ingrese_una_cadena_ 
	 newLine 
	 GetString @E
	 JMP ETIQ_114 	;Si cumple la condicion salto a la etiqueta
ETIQ_111: 
	 mov si,OFFSET @E 	;Cargo en si el origen
	 mov di,OFFSET @D 	; cargo en di el destino 
	 STRCPY	; llamo a la macro para copiar 
ETIQ_114: 
	 FLD @_2 	;Cargo operando 1
	 FLD @_1 	;Cargo operando 2
	 FADD 		;Opero
	 FSTP @_aux116 	;Almaceno el resultado en una var auxiliar
	 FLD @_aux116 	;Cargo valor 
	 FSTP @a 	; Se lo asigno a la variable que va a guardar el resultado 
	 DisplayString @__Dos_mas_uno_es_ 
	 newLine 
	 DisplayFloat @a,2 
	 newLine 
	 DisplayString @__Variable_ingresada_ 
	 newLine 
	 DisplayString @E 
	 newLine 
	 DisplayString @__Ejecucion_Exitosa_ 
	 newLine 
	 mov AX, 4C00h 	 ; Genera la interrupcion 21h
	 int 21h 	 ; Genera la interrupcion 21h

.DATA 
	@a dd ?	 ; Declaracion de Variable Numerica
	@b dd ?	 ; Declaracion de Variable Numerica
	@z dd ?	 ; Declaracion de Variable Numerica
	@c dd ?	 ; Declaracion de Variable Numerica
	@d db 30 dup (?),"$"	;Declaracion de Variable String
	@e db 30 dup (?),"$"	;Declaracion de Variable String
	@_5 dd 5.0	;Declaracion de Constant Number
	@_8 dd 8.0	;Declaracion de Constant Number
	@_2_3 dd 2.3	;Declaracion de Constant Number
	@_2 dd 2.0	;Declaracion de Constant Number
	@_40 dd 40.0	;Declaracion de Constant Number
	@_0_1 dd 0.1	;Declaracion de Constant Number
	@_3 dd 3.0	;Declaracion de Constant Number
	@_1 dd 1.0	;Declaracion de Constant Number
	@__Resultado_AVG_ db "Resultado AVG", "$", 30 dup (?)	;Declaracion de Constant String
	@_7 dd 7.0	;Declaracion de Constant Number
	@_12 dd 12.0	;Declaracion de Constant Number
	@_34 dd 34.0	;Declaracion de Constant Number
	@_10 dd 10.0	;Declaracion de Constant Number
	@__Hola_ db "Hola", "$", 30 dup (?)	;Declaracion de Constant String
	@__Holaa____Mundo_ db "Holaa    Mundo", "$", 30 dup (?)	;Declaracion de Constant String
	@__Ingrese_una_cadena_ db "Ingrese una cadena", "$", 30 dup (?)	;Declaracion de Constant String
	@__Dos_mas_uno_es_ db "Dos mas uno es", "$", 30 dup (?)	;Declaracion de Constant String
	@__Variable_ingresada_ db "Variable ingresada", "$", 30 dup (?)	;Declaracion de Constant String
	@__Ejecucion_Exitosa_ db "Ejecucion Exitosa", "$", 30 dup (?)	;Declaracion de Constant String
	@_aux2 dd ?	 ; Declaracion de Variable Numerica
	@_aux12 dd ?	 ; Declaracion de Variable Numerica
	@_aux14 dd ?	 ; Declaracion de Variable Numerica
	@_aux25 dd ?	 ; Declaracion de Variable Numerica
	@_aux36 dd ?	 ; Declaracion de Variable Numerica
	@_aux38 dd ?	 ; Declaracion de Variable Numerica
	@_aux45 dd ?	 ; Declaracion de Variable Numerica
	@_aux46 dd ?	 ; Declaracion de Variable Numerica
	@_aux48 dd ?	 ; Declaracion de Variable Numerica
	@_aux50 dd ?	 ; Declaracion de Variable Numerica
	@_aux60 dd ?	 ; Declaracion de Variable Numerica
	@_aux62 dd ?	 ; Declaracion de Variable Numerica
	@_aux71 dd ?	 ; Declaracion de Variable Numerica
	@_aux72 dd ?	 ; Declaracion de Variable Numerica
	@_aux92 dd ?	 ; Declaracion de Variable Numerica
	@_aux116 dd ?	 ; Declaracion de Variable Numerica
END MAIN
