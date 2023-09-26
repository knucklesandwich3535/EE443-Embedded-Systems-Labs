.ORG 0x0000
	RJMP ONRESET
.ORG 0x0002
	RJMP ISR_INT0   ;INT0 EXTERNAL INTERRUPT HANDLER
.ORG 0x0009
	RJMP ISR_TIMER0 ;TIMER0 OVERFLOW INTERRUPT HANDLER

.include "macros.asm"

ONRESET:
	macro_setup;
	macro_timer0;
	macro_int0;
	SEI

	LDI R31 , 80	   ;initial value
	MOV R14 , R31	   ;initialize the R14 value according to R31's assigned value

//****************************************************************

MAIN:		
	SBIS PINB , PORTB2 ;if PORTB2's button is pressed then
	RJMP LOOP1		   ;go to LOOP1
	SBIS PIND , PORTD2 ;if PORTD2's button is pressed then
	RJMP LOOP2		   ;go to LOOP2
	RJMP MAIN

LOOP1:
	SBIS PIND, PORTD2 ;if PORTD2's button is pressed too
	RJMP LOOP3		  ;then go to LOOP3
	DEC R14
	RJMP MAIN
	
LOOP2:
	SBIS PINB, PORTB2 ;if PORTB2's button is pressed too
	RJMP LOOP3        ;then go to LOOP3
    INC R14
	RJMP MAIN
    
LOOP3:
	MOV R14 , R31	  ;initialize the value of R14
	RJMP MAIN

//****************************************************************

.include "display_functions.asm"

ISR_INT0:
	CLI				;DISABLE GLOBAL INTERRUPT ENABLE
	IN R26 , SREG	;SAVE STATUS REGISTER
	;*********************************************************
	;WRITE CODE WHAT YOU WANT TO DO WHEN INT0 INTERRUPT COMES
	;***R14=0x00 R15=0x00 COUNT NUMBER START VALUES*********
	;*********************************************************
	
// R14 is already filled at above process, if we put another value into this register again, it will show this value at; whenever you press the button, it initializes
// its value by below, R16's value. As a result of this, whenever the decrement process wanted to be done; there is an unintended situation occurs.
// To solve this, below lines that goes into R14 register commented out
	;LDI	R16 , 0xA0	
	;MOV	R14 , R16	;COUNT NUMBER LOW BYTE

	LDI	R16 , 0x00
	MOV	R15 , R16	;COUNT NUMBER HIGH BYTE
	;*********************************************************
	OUT	 SREG , R26		;RELOAD STATUS REGISTER
    RETI					;RETURN FROM INT0 INTERRUPT HANDLER

ISR_TIMER0:
	macro_display R14 , R15	;DISPLAY HEX NUM.R14=LOW BYTE R15=HIGH BYTE 
    RETI					;RETURN FROM TIMER0 INTERRUPT HANDLER