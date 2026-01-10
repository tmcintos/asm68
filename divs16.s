***********************************************************************
*  divs16.s
*  asm68
*
*  Created by Tim + Gemini on 12/6/25.
***********************************************************************

***********************************************************************
* ERROR HANDLER: Replace with your assembler's actual error routine
***********************************************************************
.ERDV0
* and prints the "Divide by Zero" error message.
* Example: JSR	error_trap
	ldaa	#8	* error: divide by zero
	jmp	aserx

**********************************************************************
* DIVS16 - 16-bit Signed Integer Division (A:B / (X))
* - Returns Quotient in A:B, quotient in (X)
* - Assumes a working unsigned division routine DIV16 is available.
* - Handles sign flags and conversion to/from 2's complement.
**********************************************************************

DIVS16
	CLR	negflg	* Clear negative flag
* push divisor onto stack
	DES		* allocate stack space for divisor/remainder
	DES
	STX	xsave	* save X
	STS	ssave	* save S
	LDS	,X	* S = divisor @ X
	LDX	ssave	* X = saved S
	STS	1,X	* copy divisor to stack
* Check Sign of Divisor (X)
	BPL	.CKDVD	* If Positive or Zero, skip
* Divisor is Negative: flip negative flag and negate divisor on stack
	COM	negflg	* flip negative flag
	COM	1,X	* 1's complement MSB
	COM	2,X	* 1's complement LSB
	INC	2,X	* increment LSB
	BNE	.CKDVD
	INC	1,X	* propagate carry to MSB
.CKDVD
	LDS	ssave	* restore S
	LDX	xsave	* restore X
* Check Sign of Dividend (in A:B)
	TSTA		* Test MSB of A (Dividend)
	BPL	.DODIV	* If Positive or Zero, skip
* Dividend is Negative: Flip Sign Flag and negate A:B
	COM	negflg	* flip negative flag
* Negate A:B (2's complement: NOT A:B + 1)
	JSR	negab
.DODIV
* A:B holds ABS(Dividend), (X) holds ABS(Divisor)
* Check for DIVIDE BY ZERO
	STX	xsave
	LDX	,X	* Compare Divisor (X) to 0
	BEQ	.ERDV0	* If Divisor is zero, branch to error handler
	LDX	xsave
* DIV16 uses A:B as Dividend, Divisor from stack, and returns Quotient in A:B, remainder on stack
	BSR	DIV16	* Execute Unsigned Division (clobbers X)
* Check stored sign flag
	TST	negflg
	BEQ	.DVXIT	* If Positive, return A:B as is
* Result is Negative: Negate Quotient (A:B)
	JSR	negab
.DVXIT
	INS		* deallocate remainder
	INS
	RTS		* Return with signed quotient in A:B


MODS16
	CLR	negflg	* Clear negative flag
* push divisor onto stack
	DES		* allocate stack space for divisor/remainder
	DES
	STX	xsave	* save X
	STS	ssave	* save S
	LDS	,X	* S = divisor @ X
	LDX	ssave	* X = saved S
	STS	1,X	* copy divisor to stack
* Check Sign of Divisor (X)
	BPL	.MCKDV	* If Positive or Zero, skip
* Divisor is Negative: flip negative flag and negate divisor on stack
	COM	1,X	* 1's complement MSB
	COM	2,X	* 1's complement LSB
	INC	2,X	* increment LSB
	BNE	.MCKDV
	INC	1,X	* propagate carry to MSB
.MCKDV
	LDS	ssave	* restore S
	LDX	xsave	* restore X
* Check Sign of Dividend (in A:B)
	TSTA		* Test MSB of A (Dividend)
	BPL	.DOMOD	* If Positive or Zero, skip
* Dividend is Negative: Flip Sign Flag and negate A:B
	COM	negflg	* flip negative flag
* Negate A:B (2's complement: NOT A:B + 1)
	JSR	negab
.DOMOD
* A:B holds ABS(Dividend), (X) holds ABS(Divisor)
* Check for DIVIDE BY ZERO
	STX	xsave
	LDX	,X	* Compare Divisor (X) to 0
	BEQ	.ERDV0	* If Divisor is zero, branch to error handler
	LDX	xsave
* DIV16 uses A:B as Dividend, Divisor from stack, and returns Quotient in A:B, remainder on stack
	BSR	DIV16	* Execute Unsigned Division (clobbers X)
	PULA		* Pull remainder from stack
	PULB
* Check stored dividend sign flag
	TST	negflg
	BEQ	.MDXIT	* If Positive, return A:B as is
* Result is Negative: Negate Remainder (A:B)
	JSR	negab
.MDXIT
	RTS		* Return with signed quotient in A:B
