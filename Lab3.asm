.ORG 0x0000
	RJMP ONRESET
.ORG 0x0002
	RJMP ISR_INT0   ;INT0 EXTERNAL INTERRUPT HANDLER
.ORG 0x0009
	RJMP ISR_TIMER0 ;TIMER0 OVERFLOW INTERRUPT HANDLER
.ORG 0x000E
	RJMP ISR_ADC  ;INT0 EXTERNAL INTERRUPT HANDLER

.include "macros.asm"
.include "display_functions.asm"

ONRESET:
	macro_setup
	macro_timer0
	macro_int0
	macro_adc			; calls for register init macro, defined in macros.asm
	SEI                 ; Enable global interrupts

	;800 IN DECIMAL:
	LDI R31, 0x03	; HIGH BYTE
	LDI R30, 0x20	; LOW BYTE

MAIN:
	CBI ADCSRA,ADFR ;SINGLE CONVERSION MODE
	SBI ADCSRA,ADSC ;START CONVERSION
	
	CP R15 , R31
	BREQ LOOP1
	BRLO LED_ON
	RJMP MAIN

LOOP1:  
	CP R14 , R30
	BRLO LED_ON
	BRSH LED_OFF
	RJMP MAIN

LED_ON:
	SBI PORTB, 1
	RJMP MAIN

LED_OFF:
	CBI PORTB, 1
	RJMP MAIN

ISR_INT0:
	CLI				;DISABLE GLOBAL INTERRUPT ENABLE
	IN R26, SREG	;SAVE STATUS REGISTER
	;*******
	;WRITE CODE WHAT YOU WANT TO DO WHEN INT0 INTERRUPT COMES
	;R14=0x00 R15=0x00 COUNT NUMBER START VALUES**
	;*******
	LDI	R16, 0xFF	
	MOV	R14, R16	;COUNT NUMBER LOW BYTE
	LDI	R16, 0x00
	MOV	R15, R16	;COUNT NUMBER HIGH BYTE
	;*******
	OUT	 SREG, R26		;RELOAD STATUS REGISTER
    RETI					;RETURN FROM INT0 INTERRUPT HANDLER

ISR_TIMER0:
	macro_display R14,R15;	;DISPLAY HEX NUM.R14=LOW BYTE R15=HIGH BYTE 
    RETI					;RETURN FROM TIMER0 INTERRUPT HANDLER

ISR_ADC:
	CLI
	IN R14, ADCL         ; Read ADC low byte
	IN R15, ADCH         ; Read ADC high byte
	SBI ADCSRA,ADSC 
	RETI                 ; Return from interrupt