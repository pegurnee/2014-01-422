;p2_receiver.txt
;Receives information from the p2_transmitter chip, sends information to light up the 7-segment display
;@author: Eddie Gurnee
;@version: 1/02/2014
; uncomment following two lines if using 16f627 or 16f628.
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"	;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20.

cblock 	0x20 			;start of general purpose registers
		delayReg		;used in delay routines
		counta 			;used in delay routine 
		countb 			;used in delay routine
		led_0
		led_1
		led_2
		led_3
		led_4
		led_5
		led_6
		led_7
		sentNum
		numBits
	endc

;the following lines turn off the comparators
	movlw	0x07
	movwf	CMCON		;turn comparators off (make it like a 16F84)
	
;We must change memory banks to set the TRIS registers

	bsf		STATUS,RP0
	movlw	0x00
	movwf	TRISB			;PORTB is output
	movlw	0xFF
	movwf	TRISA			;PORTA is input
	bcf		STATUS,RP0		;return to bank 0

;actual code follows here
				movlw	b'00111111'
				movwf	led_0
				movlw	b'00000110'
				movwf	led_1
				movlw	b'01011011'
				movwf	led_2
				movlw	b'01001111'
				movwf	led_3
				movlw	b'01100110'
				movwf	led_4
				movlw	b'01101101'
				movwf	led_5
				movlw	b'01111101'
				movwf	led_6
				movlw	b'00000111'
				movwf	led_7
			
startPolling	btfsc	PORTA, 0x02
				goto	startPolling
				
				movlw	0x00		;1us
				movwf	sentNum		;2us
				movlw	0x08		;3us
				movwf	numBits		;4us
				call	initWait	;6us - back at 151us (should be 148us, sets to right before the middle of the first bit to be read)
				
readAll			call 	readIn		;153us - back at 159us, 257us - back at 263us
				call	bitWait		;161us - back at 253us
				decfsz	numBits, f	;254us
				goto	readAll		;255us
				
				btfsc	sentNum, 0x02
				goto	fourPlus
				btfsc	sentNum, 0x01
				goto	twoPlus
				btfsc	sentNum, 0x00
				goto	isOne
				goto	isZero
				
twoPlus			btfsc	sentNum, 0x00
				goto	isThree
				goto	isTwo
				
fourPlus		btfsc	sentNum, 0x01
				goto	sixPlus
				btfsc	sentNum, 0x00
				goto	isFive
				goto	isFour

sixPlus			btfsc	sentNum, 0x00
				goto	isSeven
				goto	isSix				
				
isZero			movf	led_0, w
				movwf	PORTB
				goto	startPolling
isOne			movf	led_1, w
				movwf	PORTB
				goto	startPolling
isTwo			movf	led_2, w
				movwf	PORTB
				goto	startPolling
isThree			movf	led_3, w
				movwf	PORTB
				goto	startPolling
isFour			movf	led_4, w
				movwf	PORTB
				goto	startPolling
isFive			movf	led_5, w
				movwf	PORTB
				goto	startPolling
isSix			movf	led_6, w
				movwf	PORTB
				goto	startPolling
isSeven			movf	led_7, w
				movwf	PORTB
				goto	startPolling
				
;Subroutine: initWait
;
;Precondition: 
;Postcondition: 
initWait		movlw	0x2E			;7us
				movwf	delayReg		;8us
initWait_loop	decfsz	delayReg, f
				goto	initWait_loop	
										;147us
				goto	$+1				;149us
				
				return					;151us

;Subroutine: bitWait
;
;Precondition: 
;Postcondition: 
bitWait			movlw	0x1D
				movwf	delayReg
bitWait_loop	decfsz	delayReg, f
				goto	bitWait_loop
				return

		
;Subroutine: readIn
;
;Precondition: 
;Postcondition: 
readIn	rlf		sentNum, f		;154us, 258us
		movlw	0x01			;155us, 259us
		btfsc	PORTA, 0x02		;156us should be exactly the middle of the message, 260us
		addwf	sentNum, f		;157us, 261us
		
		return					;159us, 263us


; don't forget the word 'end' (it ends the code)
	end