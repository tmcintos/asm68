**********************************************************************
* ASM68 TEST - execute with 400R
**********************************************************************
	ORG	$400

* ASCII control characters
NUL	EQU	0
CR	EQU	$0D

* WOZ MONITOR entry points:
WOZMON	EQU	$FF21	* EXIT
PRINTA	EQU	$FFB4	* ECHO A

* Main program:
MAIN	LDX	#HELLO	* HELLO
RDCHR	INX		* NXT CH
	LDAA	,X	* GET CH
	JSR	PRINTA	* OUT CH
	BNE	RDCHR	* NUL?
.MAIN	JMP	WOZMON	* RETURN

* ASCII string to print:
HELLO	FCB	NUL,CR	* \0,NL
	FCC	"Hello world!"
	FCB	CR,NUL	* NL,\0
