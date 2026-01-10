**********************************************************************
*  defs.s
*  asm68
*
*  Created by Tim McIntosh on 12/21/25.
**********************************************************************

**********************************************************************
* definitions
**********************************************************************

NUL	equ	0	* ASCII NUL
FS	equ	$01	* field separator
EMPTY	equ	$02	* empty line indicator
EOT	equ	$04	* ASCII EOT (Ctrl-D)
BS	equ	$08	* ASCII backspace
BSIN	equ	$5F	* Apple-1 uses _ key as rubout
HT	equ	$09	* ASCII horizontal tab
CR	equ	$0D	* ASCII carriage return
ESC	equ	$1B	* ASCII escape

_	equ	$7F	* we use $7F (DEL) as underscore

MPRMPT	equ	'\'	* Woz monitor prompt
PROMPT	equ	'?'

KBDDAT	equ	$D010
KBD_CR	equ	$D011

MON	equ	$FF21
ECHO	equ	$FFB4
PRBYTE	equ	$FFA2
PRHEX	equ	$FFAA

STKTOP	equ	$01FF	* (256 bytes) top of hardware stack
lnbuf	equ	$200	* (128 bytes) Apple-1 input buffer

DFLTPC	equ	$0300	* default program location

LINLEN	equ	40-4	* editor line length
MNEMON	equ	1	* mnemonic field length
COMENT	equ	3	* comment field index

*--------------------------------------------------------------------
* Placeholder used for forward references
* Note: MSB ≠ 0 to ensure direct addressing for forward references
*--------------------------------------------------------------------
INVADR	equ	$FFFF

**********************************************************************
* Symbol table entries are 6 character name (space padded) followed by
* 16-bit address. Forward reference entries follow the same format.
**********************************************************************
NAMLEN	equ	6	* symbol name length
SYMADR	equ	NAMLEN	* offset to symbol address
STESIZ	equ	8	* symbol table entry size

**********************************************************************
* characters of name may be negated to indicate attributes as follows:
**********************************************************************
REFPCR	equ	0	* negated byte 0 of fwdref = PC-relative

**********************************************************************
* uninitialized variables
**********************************************************************

lbllen	equ	$0003	* (1 byte) length of label in current line
lclflg	equ	$0004	* (1 byte) local symbol flag
psave	equ	$0005	* (1 byte) volatile flags save location
xsave	equ	$0006	* (2 bytes) volatile X save location
ssave	equ	$0008	* (2 bytes) volatile S save location
absave	equ	$000A	* (2 bytes) volatile AB save location
linptr	equ	$000C	* (2 bytes) start of current line in srcbuf
line	equ	$000E	* (2 bytes) current line number (16-bit)
fldptr	equ	$0010	* (2 bytes) pointer to current field length
prgctr	equ	$0012	* (2 bytes) current address in program
lclsym	equ	$0014	* (2 bytes) next local symbol (grows up)
gblsym	equ	$0016	* (2 bytes) next global symbol (grows down)
fwdref	equ	$0018	* (2 bytes) next forward reference (grows up)
symptr	equ	$001A	* (2 bytes) pointer to last allocated symbol
mneptr	equ	$001C	* (2 bytes) current mnemonic during search
opcptr	equ	$001E	* (2 bytes) current opcode entry during search
jmpbuf	equ	$0020	* (4 bytes) stack pointer (S) to restore
* $24-$38 reserved by wozmon
symoff	equ	$0039	* (1 byte) symbol definition offset
* $3A-$3B available
fwdrok	equ	$003C	* (1 byte) forward ref allowed?
column	equ	$003D	* (1 byte) column index (n/l commands)
mneitr	equ	$003E	* (1 byte) mnemonic search pass count
negflg	equ	$003F	* (1 byte) negative value indicator
qotflg	equ	$003F	* (1 byte) quote flag (alias of negflg)
curins	equ	$0040	* (1 byte) current instruction index
curopc	equ	$0041	* (1 byte) current opcode
curmod	equ	$0042	* (1 byte) current addressing mode
valbas	equ	$0043	* (1 byte) numeric base of expression
curopd	equ	$0044	* (2 bytes) current operand
modptr	equ	$0046	* (2 bytes) start of current module
srcptr	equ	$0048	* (2 bytes) saved position in srcbuf

datasp	equ	$0080	* (2 bytes) data stack pointer
xstksp	equ	$0082	* (2 bytes) X stack pointer

XSTKTP	equ	$007F	* (60 bytes) X stack top (grows down)
DSTKTP	equ	$00FF	* (64 bytes) data stack top (grows down)
