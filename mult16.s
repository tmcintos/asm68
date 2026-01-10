**********************************************************************
*  mult16.s
*  asm68
*
*  Created by Tim McIntosh on 12/6/25.
*
*  From Motorola M6800 User Group Library:
* - REENTRANT DOUBLE PRECISION MULTIPLY (Routine 009)
*
* Note: High word will not be correct for signed numbers, but the
*       word will be, hence this is sufficient for implementing signed
*       16-bit multiplication.
**********************************************************************


*	NAM RENTMUP
*      DOUBLE PRECISION UNSIGNED BINARY
*       MULTIPLICATION
*       (PH,PL) *  (QH,QL) --INTO-- (A,B,QH,QL)
*
*       REENTRANT CODE
*
*       SOURCE INSTRUCTIONS:  16
*       PROGRAM:              27 BYTES
*       DATA AND SCRATCH:      5 BYTES
*       RUNNING TIME:
*         MINIMUM:         558 CYCLES
*          MAXIMUM:          718 CYCLES
*
*       BOTH OPEERANDS INITIALLY IN STACK
*       AND OBTAINED BY INDEXED ADDRESSING
*
*       PRODUCT RETAINED IN REGISTERS
*       "A" (MOST SIGNIFICANT BYTE) AND
*       "B" (2ND MOST SIGNIFICANT BYTE)
*       AND IN THE SSTACK (LEAST
*       SIGNIFICANT TWO BYTES),
*
*       THIS REENTRANT CODED VERSION ASSUMES
*       THAT DATA HAS BEEN PLACED IN A STACK
*       AS INDICATED BELOW:
*
*       SP ---
*       X1 --- BLANK  (NOT USED)
*              BLANK  (NOT USED)
*              BLANK  (FOR BITS TO GO)
*              QH     (MSB OF MULTIPLIER)
*              QL     (LSB OF MULTIPLIER)
*              PH     (MSB OF MULTIPLICAND)
*              PL     (LSB OF MULTIPLICAND)
*
*       THE TOP TWO BYTES OF THE STACK ARE
*       NOT USED BY THIS PROGRAM.  THEY ARE
*       INTENDED FOR A RETURN ADDRESS IF THE
*       PROGRAM IS TO BE USED AS A
*       SUBROUTINE.  IN THE LATTER CASE THE
*       FOLLOWING STATEMENT SHOULD BE ADDED
*       AT THE END OF THE PROGRAM:
*             RTS
*
*       THE PROGRAM USES OP-CCODE TSX TO ENTER
*       AN ADDRESS X1 INTO THE INDEX REGISTER,
*       AS INDICATED ABOVE.
*
*       THE PRODUCT, COMPRISING FOUR BYTES,
*       IS SAVED IN REGISTERS "A" AND "B" AND
*       IN THE STACK AT LOCATINS INDICATED
*       ABOVE BY "QH" AND "QL".
*
*	ORG 0
*	SPC 2
MULT16
	TSX
	LDAA #16
	STAA 2,X
	CLRA
	CLRB
	ROR 3,X
	ROR 4,X
NNEXT	BCC RROTN
	ADDB 6,X
	ADCA 5,X
RROTN	RORA
	RORB
	ROR 3,X
	ROR 4,X
	DEC 2,X
	BNE NNEXT
	RTS
*	END

