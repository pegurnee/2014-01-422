;Project1.txt
;Makes an LED flash on for 275 milliseconds, then turns off for 180 milliseconds.
;@author: Eddie Gurnee
;@version: 1/02/2014
; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; DECLARE VARIABLES!!!!!!
; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20. Please refer to technical documents to see if this is OK!!

cblock 	0x20 		;start of general purpose registers
		count1		;
		counta		;
		countb 		;
	endc

;un-comment the following two lines if using 16f627 or 16f628
; FORGET THESE 2 LINES AND FUNNY STUFF HAPPENS
	movlw	0x07
	movwf	CMCON			;turn comparators off (make it like a 16F84)
	
; The following is very typical. We must change memory banks to set the TRIS registers

	bsf		STATUS,RP0
	movlw	0x00
	movwf	TRISB			;portb is output
	movlw	0xff
	movwf	TRISA			;porta is input
	bcf		STATUS,RP0		;return to bank 0

;start main code here
	
	start		movlw	0xFF		
				movwf	PORTB		;light is off at the execution of this line
				call	delay275	;
			
				movlw	0x00
				movwf	PORTB		;light is on at the execution of this line
				call	delay180	;
				goto	start
				
delay275 		call	Del250
				call	Del20
				call	Del5
				return

delay180		call	Del100
				call	Del50
				call	Del20
				call	Del10
				return
				
Del0	retlw	0x00			;delay 0mS - return immediately
Del1	movlw	d'1'			;delay 1mS
		goto	Delay
Del5	movlw	d'5'			;delay 5mS
		goto	Delay
Del10	movlw	d'10'			;delay 10mS
		goto	Delay
Del20	movlw	d'20'			;delay 20mS
		goto	Delay
Del50	movlw	d'50'			;delay 50mS
		goto	Delay
Del100	movlw	d'100'			;delay 100mS
		goto	Delay
Del250	movlw	d'250'			;delay 250 ms
Delay	movwf	count1
d1		movlw	0xC7			;delay 1mS
		movwf	counta
		movlw	0x01
		movwf	countb
Delay_0
		decfsz	counta, f
		goto	$+2
		decfsz	countb, f
		goto	Delay_0

		decfsz	count1, f
		goto	d1
		retlw	0x00

	
; don't forget the word 'end'
	end