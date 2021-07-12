;PRACTICA 4
;P2: BUS DE DATOS DE LCD
;P3.6: RS - LCD
;P3.7: E - LCD

;P1:3 - P1.0: D - A DE 74C922

;P3.1: PUERTO SERIAL
;P3.2: LECTURA DE MATRIZ
;P3.3: ASCII MODE

;TIMER 1 - DELAY 100 us

;R7: N VECES QUE SE REPITE TIMER 100 uS
;R6: CANTIDAD DE CARACTERES impresos (LCD)
;R5: CARACTER PRUEBA

DIR_DATOS equ 60H
DIR_CONVERTION equ 50H
RS equ P3.6
E equ P3.7

ORG 0H
	SJMP START
	
;EXTERNAL 0
ORG 0003H
RETI
	
;TIMER 0
ORG 000BH
RETI

;EXTERNAL 1
ORG 0013H
RETI

;TIMER 1
ORG 001BH
RETI

;SERIAL PORT
ORG 0023H
RETI
	

ORG 40H
START:
;CONF TIMER
;				T1					T0	
;			GATE !T/C M1 M0		GATE !T/C M1 M0	
	MOV TMOD, #00010001b
	
;CONF INTERRUPCIONES
;		EA - ET2 ES ET1 EX1 ET0 EX0
MOV IE, #10010101b

;CONF SERIAL
	
	ACALL LCD_INICIALIZATION
	
TEST:
	;PUEDEN UTILIZAR ESTE ESPACIO PARA PRUEBAS, SIEMPRE Y CUANDO DEJEN EL CODIGO COMO DEBER�A IR.
	MOV A, #'H'
	acall LCD_WRITE
	
	MOV A, #'0'
	acall LCD_WRITE
	
	MOV A, #'L'
	acall LCD_WRITE
	
	MOV A, #'A'
	acall LCD_WRITE
	
	
	
	SJMP $
	
	
LCD_INICIALIZATION:
	;38H - 39 us, RS = 0
	;0FH - 39 us, RS = 0
	;01H - 1.53 ms, RS = 0
	CLR RS; !COMANDO / DATO
	CLR E
	MOV P2, #01H
	MOV R7, #17D
	SETB E ; E 
	ACALL DELAY
	CLR E; E	

	MOV P2, #38H
	MOV R7, #01h; cantidad de veces que se repite t_0
	SETB E; E 
	ACALL DELAY
	CLR E; E
	
	MOV P2, #38H
	MOV R7, #01h
	SETB E ; E 
	ACALL DELAY
	CLR E; E
	
	MOV P2, #0FH
	MOV R7, #01h
	SETB E; E 
	ACALL DELAY
	CLR E; E

	MOV P2, #80H
	MOV R7, #01h
	SETB E; E 
	ACALL DELAY
	CLR E; E

	RET
	
LCD_WRITE:
;PARA ESCRIBIR EN LCD, PASAR AL ACC EL CARACTER A ESCRIBIR
	CJNE R6, #16D, LCD_WRITE_ACC
	ACALL LCD_JUMP
	MOV R6, #0H
	
LCD_WRITE_ACC:
	SETB RS; !COMANDO / DATO
	MOV P2, A; MOVER AL BUS DE LA PANTALLA EL DATO
	SETB E; E
	MOV R7, #1
	ACALL DELAY
	CLR E
	INC R6

	RET
	
LCD_JUMP:
	CLR RS
	MOV P2, #0C0H
	SETB E
	MOV R7, #1D
	ACALL DELAY
	CLR E
	RET
	
DELAY:
	MOV TH0, #HIGH(-100)
	MOV TL0, #LOW(-100)
	SETB TR0
	
POOLING:
	JNB TF0, POOLING
	CLR TF0
	
	DJNZ R7, DELAY
	
	RET
	
	SJMP $
	END