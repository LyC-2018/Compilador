del ts.txt
del Intermedia.txt
c:\GnuWin32\bin\flex Lexico.l
pause
c:\GnuWin32\bin\bison -dyv Sintactico.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o Tercera.exe
pause
pause
Tercera.exe Prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Tercera.exe
pause
