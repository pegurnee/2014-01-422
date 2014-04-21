;Nicole Arruda and Eddie Gurnee
;February 17, 2014
;Microprocessors
;Program 2: 7-digit LED
;
;p2_transmitter.asm
;
;Read a three-bit number represented as powered lines input to the chip.
;This program is burned to Nicole's chip, the transmitter.

; uncomment following two lines if using 16f627 or 16f628.
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"	;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20.

cblock 	0x20 			;start of general purpose registers
		var1			;var1 is symbolic name for location 0x20 - <use>
		var2 			;var2 is symbolic name for location 0x21 - <use>
		countp			;counter w/in Poll loop
		counts			;counter w/in Send loop
		countd			;counter w/in Delay loop
		number
	endc

;the following lines turn off the comparators
	movlw	0x07
	movwf	CMCON		;turn comparators off (make it like a 16F84)
	
;We must change memory banks to set the TRIS registers

	bsf		STATUS,RP0
	movlw	0x00
	movwf	TRISB			;PORTB is output
	movlw	b'11000011'
	movwf	TRISA			;RA0, RA1, RA6, and RA7 are input
	bcf		STATUS,RP0		;return to bank 0

;PROGRAM BODY
;While low, poll RA6 every 50µs. If high, read input,
;transmit, delay, and continue.
;(50µs = 2µs + 3µs + 43µs + 2µs)

	bsf		PORTA, 0x02	;default transmit bit is high
	
Poll_it
	;2µs (if RA6 low):
	btfsc	PORTA,0x06	;if RA6 low, delay and repeat
	call	Read_it		;if RA6 high, read input

	;3µs:
	movlw	d'8'
	movwf	countd		;counter for Delay_it
	nop
	
	;43µs (2µs + (5µs * 8) + 1µs)
	call	Delay_it
	
	;2µs:
	goto	Poll_it

;SUBROUTINE Read_it
;Clears 'number' register. Sets each bit if
;corresponding input is high.
Read_it
	clrf	number
	
	;Relate PORTA inputs to bits in 'number.'

	btfsc	PORTA, 0x01	;high-order bit
	bsf		number, 0x02
	
	btfsc	PORTA, 0x00	;middle bit
	bsf		number, 0x01
	
	btfsc	PORTA, 0x07	;low-order bit
	bsf		number, 0x00
	
	;Input is stored in 'number' (7 = 00000111).
	;Transmit byte through RA2, high-order bit first.
	
	movlw	0x08
	movwf	counts		;counter for Send_it (8 bits)
	
	bcf		PORTA,0x02	;set start bit (low)
	
	;Wait 104µs before transmission of first bit
	;(4µs + 98µs + 2µs)
	
	;4µs
	movlw	d'19'
	movwf	countd		;counter for Delay_it
	nop
	nop
	
	;98µs (2 µs + (5µs * 19) + 1µs):
	call	Delay_it
	
	;2µs
	call	Send_it
	
	bsf		PORTA, 0x02	;set stop bit (high)
	return				;return from Read_it

;SUBROUTINE Send_it
;Each iteration of Send_it takes 104µs
;(5µs + 3µs + 93µs + 3µs)
Send_it
	;5µs:
	rlf		number, f	;shift bits left
	btfsc	STATUS, C	;if carry bit = 1,	
	bsf		PORTA,0x02	;		set RA2.
	btfss	STATUS, C	;if carry bit = 0,
	bcf		PORTA,0x02	;		clear RA2.

	;3µs:
	movlw	d'18'
	movwf	countd		;counter for Delay_it
	nop
	
	;93µs (2µs + (5µs * 18) + 1µs):
	call	Delay_it

	;3µs (not including return):
	decfsz	counts		;decrement count of 8 bits
	goto	Send_it
	
	return				;return from Send_it

;SUBROUTINE Delay_it
;Total delay here, including return, is according
;to contents of countd: (5µs * countd) + 1µs
Delay_it
	;5µs (+1µs on last pass):
	nop
	nop
	decfsz	countd
	goto	Delay_it

	return				;return from Delay_it


	end