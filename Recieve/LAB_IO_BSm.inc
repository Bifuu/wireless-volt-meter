;============================================================================================.inc
;LAB_IO_BSm.inc
;
;Beymer Bevill, Jr.
;
;Version 1.0 June 27, 2011
;
;This include file holds labels for portA and portB pins, and macros:
;1) ram bank selection
;2) io pins configuration
;Always list this include before any user-defined includes.

;===========================================================================================

;begin label port pins++++++++++++++++++++++++++++++++++++++
;begin label port pins
;PORTA
RA0		EQU		0x00
RA1		EQU		0x01
RA2		EQU		0x02
RA3		EQU		0x03  	
RA4		EQU		0x04
RA5		EQU		0x05
RA6		EQU		0x06
RA7		EQU		0x07
;PORTB  
RB0		EQU		0x00
RB1		EQU		0x01
RB2		EQU		0x02
RB3		EQU		0x03  	
RB4		EQU		0x04
RB5		EQU		0x05
RB6		EQU		0x06
RB7		EQU		0x07  
;Generic Pins
D0		EQU		0x00
D1		EQU		0x01
D2		EQU		0x02
D3		EQU		0x03  	
D4		EQU		0x04
D5		EQU		0x05
D6		EQU		0x06
D7		EQU		0x07 
;end label port pins+++++++++++++++++++++++++++++++++++++++++

;bank selection macros+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bank0 macro
		bcf		STATUS, RP1
        bcf		STATUS, RP0
	endm
;
bank1 macro
		bcf		STATUS, RP1
        bsf		STATUS, RP0
	endm
;
bank2 macro
		bsf		STATUS, RP1
        bcf		STATUS, RP0
	endm
;end bank selection macros++++++++++++++++++++++++++++++++++++++++++++++++++++

;port configuration macro++++++++++++++++++++++++++++++++
ioconfgab macro prta, prtb
;prta = config byte for porta
;prtb = config byte for portb
;CMCON register = 0x07 --> all PORTA pins I/O
    bank0
    movlw	0x07
    movwf	CMCON ;make PORTA pins all I/0
    bank1
	movlw   prta
    movwf   TRISA & 0x7F
    movlw   prtb 
    movwf   TRISB & 0x7F    
    bank0
    ;clrf	PORTA
    ;clrf	PORTB
    endm
;end port configuration macro++++++++++++++++++++++++++++++++++++++++++++++	

;port configuration macro++++++++++++++++++++++++++++++++
ioconfgb macro prtb
;prtb = config byte for portb only
    bank1
	movlw   prtb
    movwf   TRISB & 0x7F 
    bank0
    endm
;end port configuration macro++++++++++++++++++++++++++++++++++++++++++++++	