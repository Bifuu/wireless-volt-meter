 
;A6_LCDlcd.INC  Header File with macro definitions for LCD init and write
;
;initLCD initializes LCD and then writes SYSTEM OK. Then it clears and
;puts cursor at home position, ready for character input.
;
;writeLCD letter sends the supplied character to the LCD
;
 
;Beymer Bevill,Jr., Author
;
;June 20, 2010
;
;       Verify Processor
;==========================================================================
;        IFNDEF __16F627a
;           MESSG "Processor-header file mismatch.  Verify selected processor."
;        ENDIF
;==========================================================================
;define io control bits
rs		EQU		0x02  ; rs = 0 instruction, rs = 1 data
en		EQU		0x03  ; strobe data on transition: en = 1 to en = 0 

;define block of registers
	cblock
	LCDTM1	
	LCDTM2	
	endc
;
;
;===========================================================================
;==========================================================================
initLCD		macro
;this macro initializes the LCD
;==========================================================================
;==========================================================================
;Configuration of Ports
    ;configure port A and B as all Output for LCD
    ;ioconfg	0x00, 0x00
	bcf		PORTA,rs ;select instruction register
;************************************************************
;Begin software initialization of LCD
;************************************************************
	call	LCDDLNG	;initial delay
	movlw	0x030  ;b00110000
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x030 first
;**********************************************
	call	LCDDLNG
    movlw	0x030  ;b00110000
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x030 first
	;movlw	0x030
	;movwf	PORTB	;b00110000
	;nop
	;bsf		PORTA,en
	;nop
	;bcf		PORTA,en	;write 0x030 second
;**********************************************
    call	LCDDLNG
    movlw	0x030  ;b00110000
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x030 third
;**********************************************
	call	LCDDLNG
	movlw	0x038	;b00111000 N=1 F=0
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x038 Function Set
;***************************************************
	call	LCDDLNG
	movlw	0x008 ;b00001000 
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x008 Display Off
;**************************************************
	call	LCDDLNG
	movlw	0x001  ;b00000001
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x001 Clear
;**************************************************
	call	LCDDLNG
	movlw	0x006   ;b00000110
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x006 Entry Mode
;***************************************************
	call	LCDDLNG
	movlw	0x00E  ;b00001110
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en	;write 0x00E Display
;*************************************************
;Initialization now complete
;*************************************************
;write first line
;enter code here
	bsf		PORTA,rs  ;select data register
;write S
	call	LCDDSHT
	movlw	0x053
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write Y
   	call	LCDDSHT
	movlw	0x059
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write S
	call	LCDDSHT
	movlw	0x053
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write T
   	call	LCDDSHT
	movlw	0x054
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write E
	call	LCDDSHT
	movlw	0x045
    movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write M
   	call	LCDDSHT
	movlw	0x04D
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write Blank
	call	LCDDSHT
	movlw	0x0A0
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write O
   	call	LCDDSHT
	movlw	0x04F
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;write K
   	call	LCDDSHT
	movlw	0x04B
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;**********************************************
;wait
	call 	LCDDLNG
	call 	LCDDLNG
    call 	LCDDLNG
	call 	LCDDLNG
;clear display and return home
	bcf		PORTA,rs ;select instruction register
	call	LCDDSHT
	movlw	0x001 
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
	call 	LCDDSHT
	bsf		PORTA,rs ;select data register
	call	LCDDSHT
;end of intro display
;****************************************************
	call 	LCDDLNG
	call 	LCDDLNG
    call 	LCDDLNG
	call 	LCDDLNG
	goto	LCDsk
;
;========================================================
LCDDSHT	;delay for I/O setup time
;=======================================================
	movlw	0x01
	movwf	LCDTM1
LCDLP1 ;outer loop
	nop
	movlw	0xFF
	movwf	LCDTM2
LCDLP2 ;inner loop
	nop
	decfsz	LCDTM2,F
	goto	LCDLP2
	decfsz	LCDTM1,F
	goto	LCDLP1
	return	
;======================================================
LCDDLNG	;delay for I/O setup time 
;=======================================================
	movlw	0xFF
	movwf	LCDTM1
LCDLP3 ;outer loop
	nop
	movlw	0xFF
	movwf	LCDTM2
LCDLP4 ;inner loop
	nop
	decfsz	LCDTM2,F
	goto	LCDLP4
	decfsz	LCDTM1,F
	goto	LCDLP3
	return
;=====================================================================	
LCDsk
;==============================================================
;=============================================================
	endm
;==============================================================
;==============================================================
;
;

;
;
;=======================================================================
;====================================================================
writeLCD	macro	Let, Reg
;this macro writes the supplied character to the LCD
;==========================================================================
;===========================================================================
;Configuration of Ports
    clrw
    addlw	Reg
    btfsc	STATUS,Z	
	bcf		PORTA,rs ;select data register
    btfss	STATUS,Z
    bsf     PORTA,rs ;select instruction register
    call	LCDDSHT
;************************************************************
;write Letter to LCD
	movf	Let,W
	movwf	DatOut
    call 	OUTPB
	nop
	bsf		PORTA,en
	nop
	bcf		PORTA,en
;
;===================================================================
	endm
;===================================================================
;====================================================================
;
	LIST
