;p2_transmitter.asm
;Depending on the number of high power wires attached, sends data to the p2_receiver chip
;@author: Nicole and Eddie

; uncomment following two lines if using 16f627 or 16f628.
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"	;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20.

cblock 	0x20 			;start of general purpose registers
		var1			;var1 is symbolic name for location 0x20 - <use>
		var2 			;var2 is symbolic name for location 0x21 - <use>
		countp			;a counter w/in Poll loop
		counts			;a counter w/in Send loop
		countd			;a counter w/in Delay loop
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
	movwf	TRISA			;PORTA is input
	bcf		STATUS,RP0		;return to bank 0

;actual code follows here

	;every ~53µs, poll RA6
	;if high, read input and transmit
Poll_it
	btfsc	PORTA,0x06
	call	Read_it		;if RA6 high, reads input
	bsf		PORTA,0x02	;stop bit
	movlw	0x10
	movwf	countp
Delay_poll
	decfsz	countp,	f
	goto	Delay_poll
	goto	Poll_it
	
Read_it
	clrf	number
	
	;PORTA bits 0, 1, and 7 take input
	;significance: 1, 0, 7
	btfsc	PORTA,0x01
	bsf		number,b'00000100'
	
	btfsc	PORTA,0x00
	bsf		number,b'00000010'
	
	btfsc	PORTA,0x07
	bsf		number,b'00000001'
	
	;input stored in number, e.g. 00000111
	;transmit through RA2
	;high-order bit first
	
	movlw	0x08		;send a byte one bit at a time
	movwf	counts
	
	bcf		PORTA,0x02	;start bit

	call	Delay_it	;delay a clock cycle
	
Send_it
	rlf		number, f	;shift bits left
	btfsc	STATUS, C	;if carry bit = 1	
	bsf		PORTA,0x02	;set RA2
	btfss	STATUS, C	;if carry bit = 0
	bcf		PORTA,0x02	;clear RA2

	call	Delay_it	;delay a clock cycle

	decfsz	counts		;decrement count of 8 bits
	goto	Send_it
	return				;return to Read_it

Delay_it
	;delay 104us (really 97?) ????
	movlw	d'20'
	movwf	countd

Delay
	nop
	nop
	decfsz	countd
	goto	Delay

	return

	;delay 250ms
;	movlw	d'250'
;	movwf	countd

;Delay_it
;	movlw	d'200'
;	movwf	count1m
;	call	Delay_1
;	decfsz	countd
;	goto	Delay_it

;	decfsz	counts
;	goto	Send_it
;	retlw	0x00	;after transmitting, return to Poll_it

;Delay_1
;	nop
;	nop
;	decfsz	count1m
;	goto	Delay_1
;	return

	end