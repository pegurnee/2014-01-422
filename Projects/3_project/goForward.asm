;goForward.txt
;Moves my robot forward
;@author: Eddie Gurnee
;@version: 3/09/2014
; uncomment following two lines if using 16f627 or 16f628.
	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"	;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)

; We are telling the assembler we want to start allocating symbolic variables starting
;    at machine location 0x20.

cblock 	0x20 			;start of general purpose registers
		dReg1			;dReg1 is used in the delay routines
		dReg2 			;dReg2 is used in the delay routines
	endc

;standard operation for using interrupts
	org 0x00
		goto	main
	org 0x04
		goto	isr

main

;the following lines turn off the comparators
			movlw	0x07
			movwf	CMCON			;turn comparators off (make it like a 16F84)
		
;enabled interrupts on B0
			bsf		INTCON, GIE		;enable interrupts
			bsf		INTCON, INTE		;B0 is the interrupt line
	
;We must change memory banks to set the TRIS registers
			bsf		STATUS,RP0
			bcf		0x81, INTEDG	;falling edge interrupts
			movlw	b'00000001'
			movwf	TRISB			;PORTB is output, with RB0 as input (for the interrupt for later)
			movlw	b'11111001'
			movwf	TRISA			;PORTA is input, with RA1 and RA2 for output for the servos
			bcf		STATUS,RP0		;return to bank 0

;actual code follows here
driveLoop	call	goForward
			goto	driveLoop

;Subroutine: goForward
;Moves the robot forward by setting the right servo to run clockwise, 
; and the left servo to run counter-clockwise
;Precondition: Left wheel servo is connected to RA2, and right wheel servo is connected to RA1
;Postcondition: Robot moves forward
goForward	movlw	b'00000110'
			movwf	PORTA			;runs both servos as high
			call	wait1ms			;for 1ms
			
			bcf		PORTA, 1		;turns off right servo
			call	wait1ms			;for 1ms

			bcf		PORTA, 2		;turns of the left servo

			call	waiter			;waits for the rest of the required time
			return

;Subroutine: waiter
;Pauses for 19500 �s, allowing the dude to move correctly
;Precondition: There exists registers to hold data for the delays
;Postcondition: 19500 instruction cycles have passed
waiter 		movlw	0x3A	;19493 cycles
			movwf	dReg1
			movlw	0x10
			movwf	dReg2
waiter_in	decfsz	dReg1, f
			goto	$+2
			decfsz	dReg2, f
			goto	waiter_in
			
			goto	$+1		;3 cycles
			nop
			
			return			;4 cycles (including call)
			
;Subroutine: wait1ms
;Pauses for 1ms, allowing the dude to move correctly
;Precondition: There exists registers to hold data for the delays
;Postcondition: 1ms has passed	
wait1ms		movlw	0xC6	;993 cycles
			movwf	dReg1
			movlw	0x01
			movwf	dReg2
wait1ms_in	decfsz	dReg1, f
			goto	$+2
			decfsz	dReg2, f
			goto	wait1ms_in
			
			goto	$+1		;3 cycles
			nop
			
			return			;4 cycles (including call)
			
;all the interrupts
isr			bcf		INTCON,INTF
		
			retfie
; don't forget the word 'end' (it ends the code)
	end