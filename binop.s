**********************************************************************
*  binop.s
*  asm68
*
*  Created by Tim McIntosh on 12/6/25.
*
* NOTE: X need not be saved/restored in these routines, as they are
*       called via JSR ,X
**********************************************************************

**********************************************************************
* opadd - add value in absave to AB and return result in AB
**********************************************************************
opadd
	addb	absave+1
	adca	absave
	rts

**********************************************************************
* opsub - subtract value in absave from AB and return result in AB
**********************************************************************
opsub
	subb	absave+1
	sbca	absave
	rts

**********************************************************************
* opand - bitwise AND AB with value in absave and return result in AB
**********************************************************************
opand
	andb	absave+1
	anda	absave
	rts

**********************************************************************
* opor - bitwise OR AB with value in absave and return result in AB
**********************************************************************
opor
	orab	absave+1
	oraa	absave
	rts

**********************************************************************
* opeor - bitwise EOR AB with value in absave and return result in AB
**********************************************************************
opeor
	eorb	absave+1
	eora	absave
	rts

**********************************************************************
* opdiv - divide AB by value in absave and return result in AB
**********************************************************************
opdiv
	staa	xsave	* save A in xsave space
	ldaa	absave+1	* push divisor on stack
	psha
	ldaa	absave
	psha
	ldaa	xsave	* restore A
	bsr	DIV16	* returns quotient in AB
	ins		* discard remainder
	ins
	rts

**********************************************************************
* opmod - perform AB % absave and return result in AB
**********************************************************************
opmod
	staa	xsave	* save A in xsave space
	ldaa	absave+1	* push divisor on stack
	psha
	ldaa	absave
	psha
	ldaa	xsave	* restore A
	bsr	DIV16	* returns quotient in AB
	pula		* pull remainder
	pulb
	rts

**********************************************************************
* opmult - multiply AB by value in absave and return result in AB
**********************************************************************
opmult
	pshb		* push LSB of multiplicand (PL)
	psha		* push MSB of multiplicand (PH)
	ldaa	absave	* load multiplier (QH,QL) int AB
	ldab	absave+1
	pshb		* push LSB of multiplier (QL)
	psha		* push MSB of multiplier (QH)
	des		* allocate space used by callee
	bsr	MULT16	* perform 16-bit multiplication
	ins		* deallocate scratch space
	pula		* pop QH (MSB discarded)
	pulb		* pop QL (LSB discarded)
	ins		* pop PH (discarded)
	ins		* pop PL (discarded)
	rts
