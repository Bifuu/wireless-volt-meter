;======================================================================
;    Filename:	    A8_AtoD.asm                                    
;    Date:          July 17, 2011                                                  
;    File Version:  1.0                                                                                                                    
;    Author:        Dustin Stover                                                                                                                     
;                                                                     
;    Project Files:                                                 
;======================================================================                                                                                                                                          
; This File has been adjusted to recive the data that is being
; trasmitted from the transmitter with the A-to-D attached to
; it. The same structure has been kept to easily switch between
; files and edit them together.                                         
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
	countBit
	countByt
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
	ioconfgab  0xF1, 0x00 ;first param= porta, second= portb
;end initial config

;initialize control lines for A/D and LCD
;>>LCD RA0(rs)=0 or instruction mode
;>>LCD RA1(en)=0 (need to set then clear to strobe data)
;>>AD RA2(ce)=1 or disabled
;>>AD RA3(sc)=1 (need to set then clear then set to read data)
;>>Don't care about upper nybble of PortA (they are input pins)
   movlw	0xF3
   movwf	PORTA
;end initialize control lines    

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

	movlw	0x30
	movwf	dat
	movwf	dat2
	movwf	dat3
    ;Task 1 (Get Data)
    ;>>Get Datta off of RA0


SAMPLE1
	btfsc	PORTA,RA0
    goto	SAMPLE1
SMPT
    btfss	PORTA,RA0
    goto	SMPT
    call	QMSDLY
    btfss	PORTA,RA0
    goto	SMPT
    call	MSDLY
;
    btfsc	PORTA,RA0
    goto	SMPT
    call	QMSDLY
    btfsc	PORTA,RA0
    goto	SMPT
    call	MSDLY
;
    btfss	PORTA,RA0
    goto	SMPT
    call	QMSDLY
    btfss	PORTA,RA0
    goto	SMPT
    call	QMSDLY
    call	QMSDLY
    call	QMSDLY
	


	
	;Sample passed
	
	call	RCVSG
	movf	dat,W
	movwf	addatW
	movf	dat2,W
	movwf	addatT
	movf	dat3,W
	movwf	addatH
	
	
      
    ;Task 2 (send data to the LCD)
    ;>>make PortB all output
    ;>>send ascii digits to LCD
    
	;call		CFPBOUT
    call		DELAY
    writeLCD 	InstDC, 0x00 ;clear and go to home position
	call		DELAY 
    writeLCD	addatW, 0x01
    call		DELAY 
    writeLCD	decpnt, 0x01
    call		DELAY 
    writeLCD	addatT, 0x01
    call		DELAY 
    writeLCD	addatH, 0x01
    call		DELAY 
	
	;continue round robbin
	goto 	    LOOP
;end main loop****************************************************

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
QMSDLY	;1QMS Delay
;=======================================================
	movlw	0x03
	movwf	timer1
QMSDLP1 ;outer loop
	nop
	movlw	0x0B
	movwf	timer2
QMSDLP2 ;inner loop
	nop
	decfsz	timer2,F
	goto	QMSDLP2
	decfsz	timer1,F
	goto	QMSDLP1
	return

;======================================================
RCVSG	;Recieve the Signal
;=======================================================
;Data Bit 0
	btfsc	PORTA,RA0
	bsf		dat,D0
	btfss	PORTA,RA0
	bcf		dat,D0
;Data Bit 1
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat,D1
	btfss	PORTA,RA0
	bcf		dat,D1
;data Bit 2
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat,D2
	btfss	PORTA,RA0
	bcf		dat,D2
;data Bit 3
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat,D3
	btfss	PORTA,RA0
	bcf		dat,D3


;data2 Bit 0
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat2,D0
	btfss	PORTA,RA0
	bcf		dat2,D0
;data2 Bit 1
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat2,D1
	btfss	PORTA,RA0
	bcf		dat2,D1
;data2 Bit 2
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat2,D2
	btfss	PORTA,RA0
	bcf		dat2,D2
;data2 Bit 3
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat2,D3
	btfss	PORTA,RA0
	bcf		dat2,D3


;data3 Bit 0
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat3,D0
	btfss	PORTA,RA0
	bcf		dat3,D0
;data3 Bit 1
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat3,D1
	btfss	PORTA,RA0
	bcf		dat3,D1
;data3 Bit 2
	btfsc	PORTA,RA0
	bsf		dat3,D2
	btfss	PORTA,RA0
	bcf		dat3,D2
;data3 Bit 3
	call	MSDLY
	btfsc	PORTA,RA0
	bsf		dat3,D3
	btfss	PORTA,RA0
	bcf		dat3,D3

	return

;begin sub for output***********************************************
;before calling, put data to be output into DatOut
OUTPB
    movf	DatOut,W
	movwf	PORTB
	return
;end sub for output****************************************************

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

