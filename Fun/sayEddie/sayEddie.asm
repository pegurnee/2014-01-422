;sayEddie.txt
;Using a 7-segment LED, have it display "EddIE"
;@author: Eddie Gurnee
;@version: 1/02/2014
; uncomment following two lines if using 16f627 or 16f628.
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"	;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20.

cblock 	0x20 			;start of general purpose registers
		count1 			;used in delay routine
		counta 			;used in delay routine 
		countb 			;used in delay routine
		e
		d
		i
		
	endc
	
;the following lines turn off the comparators
	movlw	0x07
	movwf	CMCON		;turn comparators off (make it like a 16F84)
	
;We must change memory banks to set the TRIS registers

	bsf		STATUS,RP0
	movlw	0x00
	movwf	TRISB			;PORTB is output
	movlw	0xff
	movwf	TRISA			;PORTA is input
	bcf		STATUS,RP0		;return to bank 0

;actual code follows here
		movlw	0x9E
		movwf	e
		movlw	0x7A
		movwf	d
		movlw	0x60
		movwf	i
		
start	movf	e, w
		call	display
		movf	d, w
		call	display
		movf	d, w
		call	display
		movf	i, w
		call	display
		movf	e, w
		call	display
		call	del_50
		goto	start
	
;Subroutine: display
;Displays a digit on a seven-segment display
;Precondition: the hexcode for a 7-segment display digit is in the 'w' register
;Postcondition: the digit is displayed on the 7-segment display, and ~250 milliseconds pass
display	bsf		STATUS,RP0
		movwf	TRISB
		bcf		STATUS,RP0
		call	del_250
		bsf		STATUS,RP0
		clrf	TRISB
		bcf		STATUS,RP0
		call	del_10
		return
		
;Subroutine: delay
;Delays for a span of time - taken directly from http://www.emunix.emich.edu/~sverdlik/COSC422/PICDelay.html
;Made a few adjustments for style
;Precondition: nothing specific
;Postcondition: the program delays for a variety of times, and 0x00 is in the 'w' register
del_0	retlw	0x00			;delay 0ms - return immediately
del_1	movlw	0x01			;delay 1ms
		goto	delay
del_5	movlw	0x05			;delay 5ms
		goto	delay
del_10	movlw	0x0A			;delay 10ms
		goto	delay
del_20	movlw	0x14			;delay 20ms
		goto	delay
del_50	movlw	0x32			;delay 50ms
		goto	delay
del_100	movlw	0x64			;delay 100ms
		goto	delay
del_250	movlw	0xFA			;delay 250ms

delay	movwf	count1
d_in	movlw	0xC7			;delay 1mS
		movwf	counta
		movlw	0x01
		movwf	countb
d_loop	decfsz	counta, f
		goto	$+2
		decfsz	countb, f
		goto	d_loop
		decfsz	count1	,f
		goto	d_in
		retlw	0x00
		
; don't forget the word 'end' (it ends the code)
	end