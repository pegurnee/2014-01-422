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

cblock 	0x20 			;start of general purpose registers
		outLoop			;outLoop is symbolic name for location 0x20 - used in both subroutines for the outerloop
		inLoop 			;inLoop is symbolic name for location 0x21 - used in both subroutines for inner loops
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
	
	start		movlw	0x00		
				movwf	PORTB		;light is off at the execution of this line
				call	delay275	;more accurately, delay274_996
			
				movlw	0xFF
				movwf	PORTB		;light is on at the execution of this line
				call	delay180	;also more accurately delay179_994
				goto	start
				
;Subroutine: delay275
;Used to delay the program for 274_996 microseconds (approximately 275 milliseconds)
;Precondition: there are locations declared for inLoop and outLoop
;Postcondition: 274_996 microseconds have passed, and inLoop and outLoop both have 0x00
delay275		movlw	0xCC			;decimal 204
				movwf	outLoop
			
d275_outer		movlw	0x16		;decimal 22
				movwf	inLoop
			
	d275_inner1	decfsz	inLoop, f
				goto	d275_inner1
				nop
			
				movlw	0x3D		;decimal 61
				movwf	inLoop
	d275_inner2	decfsz	inLoop, f
				goto	d275_inner2
				nop
			
				decfsz	outLoop, f
				goto	d275_outer
				nop					;helps keep the math beautiful (offsets the -1 microsecond from skipping goto)
			
			return

;Subroutine: delay180
;Used to delay the program for 149_994 milliseconds (approximately 180 milliseconds)
;Precondition: there are locations declared for inLoop and outLoop
;Postcondition: 194_994 microseconds have passed, and inLoop and outLoop both have 0x00
delay180		movlw	0xCD		;decimal 205
				movwf	outLoop
			
d180_outer		movlw	0x17		;decimal 23
				movwf	inLoop
			
	d180_inner1	decfsz	inLoop, f
				goto	d180_inner1
				nop
				
				movlw	0x26		;decimal 38
				movwf	inLoop
	d180_inner2	decfsz	inLoop, f
				goto	d180_inner2
				nop
				
				decfsz	outLoop, f
				goto	d180_outer
				nop					;helps keep the math beautiful (offsets the -1 microsecond from skipping goto)
			
			return
	
; don't forget the word 'end'
	end

