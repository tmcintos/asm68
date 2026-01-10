**********************************************************************
*  setjmp.s
*  asm68
*
*  Created by Tim McIntosh on 12/6/25.
**********************************************************************

* jmpbuf:
*	(2 bytes) program counter (PC)
*	(2 bytes) stack pointer (S)

**********************************************************************
* setjmp(jmpbuf) - store context in jmpbuf (X), returns result in AB
*	=0 on initial call
*	=val from lngjmp otherwise
**********************************************************************
setjmp
	pula		* pull return address from stack into AB
	pulb
	staa	0,x	* store return address to restore at X
	stab	1,x
	sts	2,x	* store stack pointer to restore at X+2
	des		* restore stack pointer
	des
	clra		* return $0000
	clrb
	rts

**********************************************************************
* lngjmp(jmpbuf, val) - return val (AB) to context in jmpbuf (X)
**********************************************************************
lngjmp
	staa	absave	* save A
	lds	2,x	* restore stack pointer
	ldaa	1,X	* load LSB of return address
	psha		* push it
	ldaa	0,X	* load MSB of return address
	psha		* push it
	ldaa	absave	* restore A
	bne	.ljend
	tstb
.ljend	rts
