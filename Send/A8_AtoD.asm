;======================================================================
;    Filename:	    A8_AtoD.asm                                    
;    Date:          July 17, 2011                                                  
;    File Version:  1.0                                                                                                                    
;    Author:        Dustin Stover                                                                                                                     
;                                                                     
;    Project Files:                                                 
;======================================================================                                                                                                                                          
; This code is applied to the PIC in the transmitter circuit. It will
; handle reading voltage with an external Analog to Digital Converter
; and then push the digital signal to an external transmitter to be sent
; and read by the Reciever and the PIC attached to it.                                              
;======================================================================                                                                                                                                   

;BEGIN CONFIGS AND LABELING==============================================

;identify chip and include the header file for this chip
	list      p=16f627a       
	#include <p16f627a.inc>  
	
	errorlevel -219    
	
;enable the internal 4MHz rc clock and output (1/4) on clock2
;enable poweron reset and master clear
;disable code protect, watchdog timer, brownout, low voltage reset, etc...

	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _LVP_OFF

;assign labels to port pins
	
   #include <LAB_IO_BSm.inc>

;end assign labels

;assign labels to bank 0 data
	cblock 0x20
	DatOut ;temp storage and manipulation for output
    DatB0D1 ;data bank0 data #1
	DatB0D2
    DatB0D3
    DatB0D4
    InstR1
    InstR2
    InstDC
    timer1
    timer2
    carry
    decpnt
	dat
	dat2
	dat3
	endc
;end assign labels to ram locations

;macros inserted and additional ram labels (variable names)
   	
   #include <AtoDm.inc>
   #include <LCDm.inc>
  
;END CONFIGS AND LABELING====================================================

;BEGIN PROGRAM CODE=======================================================
	ORG     0x000             ; processor reset vector
	goto    START             ; go to beginning of program
	ORG     0x004             ; interrupt vector location

;>>covert a nybble to an ASCII character
ASCII
    andlw	0x0F
	addwf	PCL,F
    retlw	0x30  ;hex digit 0
    retlw	0x31
    retlw	0x32
    retlw	0x33
    retlw	0x34
    retlw	0x35
    retlw	0x36
    retlw	0x37
    retlw	0x38
    retlw	0x39  ;hex digit 9
    retlw	0x41  ;hex digit A
    retlw	0x42   ;B
    retlw	0x43   ;C
    retlw	0x44   ;D
    retlw	0x45   ;E
    retlw	0x46  ;hex digit F
;end convert nybble to ascii****************************************************


START
;initialize data
    ;use direct addressing
	bank0
    movlw 	0x30
	movwf	DatB0D1 ;& 0x7F
	movlw 	0x31
	movwf	DatB0D2 ;& 0x7F
	movlw 	0x32
	movwf	DatB0D3 ;& 0x7F
	movlw 	0x33
	movwf	DatB0D4 ;& 0x7F
    movlw   0x2E
    movwf	decpnt
    movlw 	0x80 ;b1000 0000
	movwf	InstR1 ;& 0x7F  ;move to position 00h
	movlw 	0xC0   ;b1100 0000
    ;movlw 	0x88   ;b1000 1000
	movwf	InstR2 ;& 0x7F  ;move to position 40h
	movlw 	0x01
	movwf	InstDC ;& 0x7F  ;clear display and go home position 00h
    clrf	carry
;end initialize registers 

;initial configure Ports: PortA: (7...0)=(1111 0000)=0xF0, PortB: all input
;PortA low nybble=controls for LCD/AD, up nybble=optional additional I/O
;PortB multiplexed between LCD and A/D
;RA0=RS, RA1=E, RB0-RB7 of PIC to D0-D7 of LCD
;RA2=ce , RA3=sa , RB0-RB7 of PIC to D0-D7 of A/D 
	ioconfgab  0xF0, 0xFF ;first param= porta, second= portb
;end initial config

;initialize control lines for A/D and LCD
;>>LCD RA0(rs)=0 or instruction mode
;>>LCD RA1(en)=0 (need to set then clear to strobe data)
;>>AD RA2(ce)=1 or disabled
;>>AD RA3(sc)=1 (need to set then clear then set to read data)
;>>Don't care about upper nybble of PortA (they are input pins)
;end initialize control lines    
	bsf	PORTA, RA2
;initialize LCD  
	initLCD
;end initialization of LCD

;test out the LCD
;>>write 0123 to first line, clear
;>>write 0123 to second line, clear
   writeLCD	DatB0D1, 0x01
   call		DELAY
   writeLCD DatB0D2, 0x01
   call		DELAY
   writeLCD	DatB0D3, 0x01 
   call		DELAY 
   writeLCD DatB0D4, 0x01
   call 	BIGDLY 
   writeLCD InstDC, 0x00
   call		DELAY
   writeLCD InstR2, 0x00
   call		DELAY
   writeLCD	DatB0D1, 0x01
   call		DELAY
   writeLCD DatB0D2, 0x01
   call		DELAY
   writeLCD	DatB0D3, 0x01 
   call		DELAY 
   writeLCD DatB0D4, 0x01
   call 	BIGDLY
   writeLCD InstDC, 0x00
   call		DELAY  

LOOP
    ;Task 1 (input data from A/D):
    ;>>make PortB all input
    ;>>chip enable the A/D (use RA2)
    ;>>strobe the data from the A/D into Pic (use RA3)
    ;>>read raw data into addat
    ;>>data ready short time after negative pulse: low__wait__high

    ;call	CFPBIN
    call	DELAY
    bcf		PORTA,ce
    bsf		PORTA,sc
    call	DELAY
    bcf		PORTA,sc
    call	DELAY
    bsf		PORTA,sc
    call	DELAY
    movf	PORTB,W
    ;incf	count,F
    ;movf	count,W
    movwf	addat    

    ;Task 2 (process the A/D data (addat))
    ;>>Max hex input is 0xFF or 255. We want the display
    ;>>to be a max of 500 or 5.00. Soo...multiply input
    ;>>by 2 (or rrl one time) mentally and this will give
    ;>>us 510, a little big, but good enough for us.

	clrf	carry
    clrf	addatW
    clrf	addatT
    clrf	addatH
    rlf		addat,F	
    btfsc	STATUS,C
    bsf		carry,D0
CONTW
    movlw	0x64
    subwf	addat,F
    btfss	STATUS,C ;C=1 means positive
    goto    NEGW   ;subtracted to much restore and go to next digit
    incf	addatW,F
    goto    CONTW
NEGW
    btfsc	carry,D0
    goto	BIG
    movlw	0x64    ;restore addat back to positive value
    addwf	addat,F
    goto	CONTT
BIG  ;this will only be called once at most...
	clrf	carry
    movlw	0xFF
    addwf	addat,F
    incf	addatW,F ;increment W digit
    goto	CONTW 
CONTT
    movlw	0x0A
    subwf	addat,F
    btfss	STATUS,C  ;C=1 means positive
    goto	NEGT
    incf	addatT,F
    goto	CONTT
NEGT
    movlw	0x0A
    addwf	addat,F
    ;what's left in addat = the addatH!
    movf	addat,W
    movwf	addatH  

 
    ;convert the decimal digits to ascii
    movf	addatW,W
    ;movlw	0x07
    call	ASCII
    movwf	addatW
	;
    movf	addatT,W
    ;movlw	0x05
    call	ASCII
    movwf	addatT
    ;
    movf	addatH,W
    ;movlw	0x03
    call	ASCII
    movwf	addatH
  
    ;Task 3 (send data to other PIC)
    ;>>SEND DATA ON RA7
    ;>>send ascii digits to other  PIC
    

	movf	addatW,W
	movwf	dat
	movf	addatT,W
	movwf	dat2
	movf	addatH,W
	movwf	dat3
	call	SNDSG
	
	;continue round robbin
    call		MSDLY
	goto 	    LOOP
;end main loop****************************************************

;begin sub for output***********************************************
;before calling, put data to be output into DatOut
OUTPB
    movf	DatOut,W
	movwf	PORTB
	return
;end sub for output****************************************************

;======================================================
SNDSG	;Send the Signal
;=======================================================
;Start Signal
	bcf		PORTA,RA2
	call	MSDLY
	bsf		PORTA,RA2
	call	MSDLY
;
	bcf		PORTA,RA2
	call	MSDLY
	bsf		PORTA,RA2
	call	MSDLY
	
;Data Bit 0
	btfsc	dat,D0
	bsf		PORTA,RA2
	btfss	dat,D0
	bcf		PORTA,RA2
;Data Bit 1
	call	MSDLY
	btfsc	dat,D1
	bsf		PORTA,RA2
	btfss	dat,D1
	bcf		PORTA,RA2
;Data Bit 2
	call	MSDLY
	btfsc	dat,D2
	bsf		PORTA,RA2
	btfss	dat,D2
	bcf		PORTA,RA2
;Data Bit 3
	call	MSDLY
	btfsc	dat,D3
	bsf		PORTA,RA2
	btfss	dat,D3
	bcf		PORTA,RA2


;Data Bit 0
	call	MSDLY
	btfsc	dat2,D0
	bsf		PORTA,RA2
	btfss	dat2,D0
	bcf		PORTA,RA2
;Data Bit 1
	call	MSDLY
	btfsc	dat2,D1
	bsf		PORTA,RA2
	btfss	dat2,D1
	bcf		PORTA,RA2
;Data Bit 2
	call	MSDLY
	btfsc	dat2,D2
	bsf		PORTA,RA2
	btfss	dat2,D2
	bcf		PORTA,RA2
;Data Bit 3
	call	MSDLY
	btfsc	dat2,D3
	bsf		PORTA,RA2
	btfss	dat2,D3
	bcf		PORTA,RA2

;Data Bit 0
	call	MSDLY
	btfsc	dat3,D0
	bsf		PORTA,RA2
	btfss	dat3,D0
	bcf		PORTA,RA2
;Data Bit 1
	call	MSDLY
	btfsc	dat3,D1
	bsf		PORTA,RA2
	btfss	dat3,D1
	bcf		PORTA,RA2
;Data Bit 2
	call	MSDLY
	btfsc	dat3,D2
	bsf		PORTA,RA2
	btfss	dat3,D2
	bcf		PORTA,RA2
;Data Bit 3
	call	MSDLY
	btfsc	dat3,D3
	bsf		PORTA,RA2
	btfss	dat3,D3
	bcf		PORTA,RA2


;End Signal
	call	MSDLY
	bsf		PORTA,RA2
	call	MSDLY
	call	MSDLY
	return

;======================================================
MSDLY	;1MS Delay
;=======================================================
	movlw	0x0C
	movwf	timer1
MSDLP1 ;outer loop
	nop
	movlw	0x0B
	movwf	timer2
MSDLP2 ;inner loop
	nop
	decfsz	timer2,F
	goto	MSDLP2
	decfsz	timer1,F
	goto	MSDLP1
	return

;======================================================
GDLY	;1MS Delay
;=======================================================
	movlw	0x02
	movwf	timer1
GDLP1 ;outer loop
	nop
	movlw	0x05
	movwf	timer2
GDLP2 ;inner loop
	nop
	decfsz	timer2,F
	goto	GDLP2
	decfsz	timer1,F
	goto	GDLP1
	return

SNDZ
	bsf		PORTA,RA2
	call	MSDLY
	bcf		PORTA,RA2
	return

SNDO
	bcf		PORTA,RA2
	call	MSDLY
	bsf		PORTA,RA2
	return

;begin sub for configuration change PortB************************************
;>>change PortB to all Input
CFPBIN   
	ioconfgb  0xFF
    call		DELAY
	return
;>>change PortB to all Output
CFPBOUT
	ioconfgb  0x00
    call		DELAY
	return
;end sub for conf change pB****************************************************

;>>covert a nybble to an ASCII character
ASCI2
    andlw	0x0F
	addwf	PCL,F
    retlw	0x30  ;hex digit 0
    retlw	0x31
    retlw	0x32
    retlw	0x33
    retlw	0x34
    retlw	0x35
    retlw	0x36
    retlw	0x37
    retlw	0x38
    retlw	0x39  ;hex digit 9
    retlw	0x41  ;hex digit A
    retlw	0x42   ;B
    retlw	0x43   ;C
    retlw	0x44   ;D
    retlw	0x45   ;E
    retlw	0x46  ;hex digit F
;end convert nybble to ascii****************************************************

;begin delay code*********************************************************	
DELAY
;delay 
	movlw	0x0F
	movwf	timer1
Dloop1 ;outer loop
	nop
	movlw	0xFF
	movwf	timer2
Dloop2 ;inner loop
	decfsz	timer2,F
	goto	Dloop2
	decfsz	timer1,F
	goto	Dloop1
	return
;end delay code*****************************************************

;begin delay code*********************************************************	
DELAYM
;delay 
	movlw	0xFF
	movwf	timer1
Dloop3 ;outer loop
	nop
	movlw	0xFF
	movwf	timer2
Dloop4 ;inner loop
	decfsz	timer2,F
	goto	Dloop4
	decfsz	timer1,F
	goto	Dloop3
	return
;end delay code*****************************************************

;begin delay code***************************************************	
BIGDLY
;delay 
    call	DELAYM  
    call	DELAYM  
    call	DELAYM  
    call	DELAYM  
    call	DELAYM  
    call	DELAYM  
    call	DELAYM   
	return
;end delay code*****************************************************
		
	END  

;END PROGRAM CODE=======================================================                    

