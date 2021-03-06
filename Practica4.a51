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

DIR_DATOS equ 60H
DIR_HEXA equ 0220H
DIR_CONVERTION equ 0200H
RS equ P3.6
E equ P3.7

ORG 0H
	SJMP START
	
;EXTERNAL 0
ORG 0003H
	AJMP I_EX_0
	
;TIMER 0
;ORG 000BH
;RETI

;EXTERNAL 1
ORG 0013H
	CLR IE1
	ACALL ENVIAR
RETI

;TIMER 1
;ORG 001BH
;RETI

;SERIAL PORT
;ORG 0023H
;RETI
	

ORG 40H
START:
	;CONF TIMER
	MOV TH1, #-3
	MOV P1, #0FFH
	;				T1					T0	
	;			GATE !T/C M1 M0		GATE !T/C M1 M0	
	MOV TMOD, #00100001b 
	
	;CONF INTERRUPCIONES
	;		EA - ET2 ES ET1 EX1 ET0 EX0
	MOV IE, #10010101b
	setb IT0
	SETB IT1
	MOV R0, #DIR_DATOS

	;CONF SERIAL
	MOV SCON, #01000000B	;UART 8 BITS BANDERAS LIMPIAS

	ACALL LCD_INICIALIZATION
	MOV R6, #0H
	MOV R1, #0H
	
MAIN:
	JB P3.5, MAIN
	MOV R5, #1D
	SJMP MAIN
	
LCD_INICIALIZATION:
	;38H - 39 us, RS = 0
	;0FH - 39 us, RS = 0
	;01H - 1.53 ms, RS = 0
	CLR RS; !COMANDO / DATO
	CLR E	

	MOV P2, #38H
	MOV R7, #01h; cantidad de veces que se repite t_0
	SETB E; E 
	ACALL DELAY
	CLR E; E
	
	MOV R7, #01h; cantidad de veces que se repite t_0
	ACALL DELAY
	
	MOV P2, #38H
	MOV R7, #01h
	SETB E ; E 
	ACALL DELAY
	CLR E; E
	
	MOV R7, #01h; cantidad de veces que se repite t_0
	ACALL DELAY

	MOV P2, #38H
	MOV R7, #01h
	SETB E ; E 
	ACALL DELAY
	CLR E; E
	
	MOV R7, #01h; cantidad de veces que se repite t_0
	ACALL DELAY

	MOV P2, #01H
	MOV R7, #17D
	SETB E ; E 
	ACALL DELAY
	CLR E; E
	
	MOV R7, #01h; cantidad de veces que se repite t_0
	ACALL DELAY
	
	MOV P2, #0FH
	MOV R7, #01h
	SETB E; E 
	ACALL DELAY
	CLR E; E
	
	MOV R7, #01h; cantidad de veces que se repite t_0
	ACALL DELAY

	MOV P2, #80H
	MOV R7, #01h
	SETB E; E 
	ACALL DELAY
	CLR E; E
	
	MOV R7, #01h; cantidad de veces que se repite t_0
	ACALL DELAY

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
	MOV TH0, #HIGH(-1000)
	MOV TL0, #LOW(-1000)
	SETB TR0
	
POOLING:
	JNB TF0, POOLING
	CLR TF0
	
	DJNZ R7, DELAY
	
	RET
	
ENVIAR_DATO: 
	SETB TR1 
	SETB T1
	MOV SBUF, @R1		
	JNB TI, $ ;SI NO TERMINA DE TRANSMITIR BRINCA A SI MISMO
	CLR TI
	INC R1	;AUMENTAMOS EL NUMERO DE DATOS ENVIADOS
	SJMP ENV	

ENVIAR:		;R1 DIRECCION DATO A ENVIAR, R0: DIRECCION MAXIMA, R4: DATOS ENVIADOS
	MOV R1, #DIR_DATOS	;DIR DE DATO A ENVIAR
ENV:	
	MOV A, R1			;DIR DE DATO A ENVIAR
	CJNE A, 0, ENVIAR_DATO	//COMPARE A(DATO GUARDADO QUE VA AUMENTANDO) CON DIRECCION MAXIMA
	RET
	
READ_MATRICIAL:
	mov A,P1; leer dato
	anl A,#0FH; limpiar 
	;ANTES DE AQUI, GUARDAR EN DPTR DIRECCION A CONVERTIR
	
	MOVC A, @A+DPTR; Mover al acc la conversi?n
	
	RET
	
SAVE_DATA:
	mov @R0, A
	INC R0
	RET
	
I_EX_0:
	CLR IE0
	
ASCII_HIGH:
	CJNE R5, #1D, ASCII_LOW
	
	MOV DPH, #HIGH(DIR_HEXA)
	MOV DPL, #LOW(DIR_HEXA)
	ACALL READ_MATRICIAL
	SWAP A
	MOV R4, A
	INC R5
	RETI
	
ASCII_LOW:
	CJNE R5, #2D, NORMAL
	MOV DPH, #HIGH(DIR_HEXA)
	MOV DPL, #LOW(DIR_HEXA)
	ACALL READ_MATRICIAL
	
	ORL A, R4
	MOV R4, A
	MOV R5, #0D
	
	ACALL LCD_WRITE
	ACALL SAVE_DATA
	RETI
	
NORMAL:
	MOV DPH, #HIGH(DIR_CONVERTION)
	MOV DPL, #LOW(DIR_CONVERTION)
	;Leer dato
	ACALL READ_MATRICIAL
	
	;Imprimir dato
	ACALL LCD_WRITE	
	
	;Guardar dato
	ACALL SAVE_DATA
	RETI

	ORG DIR_CONVERTION
	DB 'D'	;0
	DB 'B'	;1
	DB 'C'	;2
	DB 'A'	;3
	DB '0'	;4
	DB '5'	;5
	DB '8'	;6
	DB '2'	;7
	DB 'E'	;8
	DB '6'	;9
	DB '9'	;10
	DB '3'	;11
	DB 'F'	;12
	DB '4'	;13
	DB '7'	;14	
	DB '1'	;15
		
	ORG DIR_HEXA
	DB 0DH	;0
	DB 0BH	;1
	DB 0CH	;2
	DB 0AH	;3
	DB 00H	;4
	DB 05H	;5
	DB 08H	;6
	DB 02H	;7
	DB 0EH	;8
	DB 06H	;9
	DB 09H	;10
	DB 03H	;11
	DB 0FH	;12
	DB 04H	;13
	DB 07H	;14	
	DB 01H	;15

	
	END