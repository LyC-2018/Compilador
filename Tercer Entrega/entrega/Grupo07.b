tasm.exe /la /zi Final.asm
tasm.exe /la numbers.asm
tlink.exe /v Final.obj numbers.obj
Final.exe