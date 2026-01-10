**********************************************************************
*  opcode.s
*  asm68
*
*  Created by Tim McIntosh on 12/6/25.
**********************************************************************

* addressing modes - note modes requiring an operand are represented by a bitmask
accinh	equ	$0	* acc and inh are considered equivalent
acc	equ	accinh
inh	equ	accinh
imm16	equ	$1	* #<2-byte expr>
imm	equ	$2|imm16	* #<1-byte expr> allowed to match imm16
idx	equ	$4	* [1-byte expr],x
rel	equ	$8	* <expr>
ext	equ	$10|rel	* <2-byte expr> allowed to match rel
dir	equ	$20|ext|rel	* <1-byte expr> allowed to match ext or rel

* instructions
ABA	equ	$1
ADCA	equ	$2
ADCB	equ	$3
ADDA	equ	$4
ADDB	equ	$5
ANDA	equ	$6
ANDB	equ	$7
ASLA	equ	$8
ASLB	equ	$9
ASL	equ	$a
ASRA	equ	$b
ASRB	equ	$c
ASR	equ	$d
BCC	equ	$e
BCS	equ	$f
BEQ	equ	$10
BGE	equ	$11
BGT	equ	$12
BHI	equ	$13
BHS	equ	$14
BLO	equ	$15
BITA	equ	$16
BITB	equ	$17
BLE	equ	$18
BLS	equ	$19
BLT	equ	$1a
BMI	equ	$1b
BNE	equ	$1c
BPL	equ	$1d
BRA	equ	$1e
BSR	equ	$1f
BVC	equ	$20
BVS	equ	$21
CBA	equ	$22
CLC	equ	$23
CLI	equ	$24
CLRA	equ	$25
CLRB	equ	$26
CLR	equ	$27
CLV	equ	$28
CMPA	equ	$29
CMPB	equ	$2a
COMA	equ	$2b
COMB	equ	$2c
COM	equ	$2d
CPX	equ	$2e
DAA	equ	$2f
DECA	equ	$30
DECB	equ	$31
DEC	equ	$32
DES	equ	$33
DEX	equ	$34
EORA	equ	$35
EORB	equ	$36
INCA	equ	$37
INCB	equ	$38
INC	equ	$39
INS	equ	$3a
INX	equ	$3b
JMP	equ	$3c
JSR	equ	$3d
LDAA	equ	$3e
LDAB	equ	$3f
LDS	equ	$40
LDX	equ	$41
LSRA	equ	$42
LSRB	equ	$43
LSR	equ	$44
NEGA	equ	$45
NEGB	equ	$46
NEG	equ	$47
NOP	equ	$48
ORAA	equ	$49
ORAB	equ	$4a
PSHA	equ	$4b
PSHB	equ	$4c
PULA	equ	$4d
PULB	equ	$4e
ROLA	equ	$4f
ROLB	equ	$50
ROL	equ	$51
RORA	equ	$52
RORB	equ	$53
ROR	equ	$54
RTI	equ	$55
RTS	equ	$56
SBA	equ	$57
SBCA	equ	$58
SBCB	equ	$59
SEC	equ	$5a
SEI	equ	$5b
SEV	equ	$5c
STAA	equ	$5d
STAB	equ	$5e
STS	equ	$5f
STX	equ	$60
SUBA	equ	$61
SUBB	equ	$62
SWI	equ	$63
TAB	equ	$64
TAP	equ	$65
TBA	equ	$66
TPA	equ	$67
TSTA	equ	$68
TSTB	equ	$69
TST	equ	$6a
TSX	equ	$6b
TXS	equ	$6c
WAI	equ	$6d
EQU	equ	$6e	* pseudo-op
ORG	equ	$6f	* pseudo-op
FCB	equ	$70	* pseudo-op
FCC	equ	$71	* pseudo-op
FDB	equ	$72	* pseudo-op
mnemon
	FCC	"ABA "	* $1
	FCC	"ADCA"	* $2
	FCC	"ADCB"	* $3
	FCC	"ADDA"	* $4
	FCC	"ADDB"	* $5
	FCC	"ANDA"	* $6
	FCC	"ANDB"	* $7
	FCC	"ASLA"	* $8
	FCC	"ASLB"	* $9
	FCC	"ASL "	* $a
	FCC	"ASRA"	* $b
	FCC	"ASRB"	* $c
	FCC	"ASR "	* $d
	FCC	"BCC "	* $e
	FCC	"BCS "	* $f
	FCC	"BEQ "	* $10
	FCC	"BGE "	* $11
	FCC	"BGT "	* $12
	FCC	"BHI "	* $13
	FCC	"BHS "	* $14
	FCC	"BLO "	* $15
	FCC	"BITA"	* $16
	FCC	"BITB"	* $17
	FCC	"BLE "	* $18
	FCC	"BLS "	* $19
	FCC	"BLT "	* $1a
	FCC	"BMI "	* $1b
	FCC	"BNE "	* $1c
	FCC	"BPL "	* $1d
	FCC	"BRA "	* $1e
	FCC	"BSR "	* $1f
	FCC	"BVC "	* $20
	FCC	"BVS "	* $21
	FCC	"CBA "	* $22
	FCC	"CLC "	* $23
	FCC	"CLI "	* $24
	FCC	"CLRA"	* $25
	FCC	"CLRB"	* $26
	FCC	"CLR "	* $27
	FCC	"CLV "	* $28
	FCC	"CMPA"	* $29
	FCC	"CMPB"	* $2a
	FCC	"COMA"	* $2b
	FCC	"COMB"	* $2c
	FCC	"COM "	* $2d
	FCC	"CPX "	* $2e
	FCC	"DAA "	* $2f
	FCC	"DECA"	* $30
	FCC	"DECB"	* $31
	FCC	"DEC "	* $32
	FCC	"DES "	* $33
	FCC	"DEX "	* $34
	FCC	"EORA"	* $35
	FCC	"EORB"	* $36
	FCC	"INCA"	* $37
	FCC	"INCB"	* $38
	FCC	"INC "	* $39
	FCC	"INS "	* $3a
	FCC	"INX "	* $3b
	FCC	"JMP "	* $3c
	FCC	"JSR "	* $3d
	FCC	"LDAA"	* $3e
	FCC	"LDAB"	* $3f
	FCC	"LDS "	* $40
	FCC	"LDX "	* $41
	FCC	"LSRA"	* $42
	FCC	"LSRB"	* $43
	FCC	"LSR "	* $44
	FCC	"NEGA"	* $45
	FCC	"NEGB"	* $46
	FCC	"NEG "	* $47
	FCC	"NOP "	* $48
	FCC	"ORAA"	* $49
	FCC	"ORAB"	* $4a
	FCC	"PSHA"	* $4b
	FCC	"PSHB"	* $4c
	FCC	"PULA"	* $4d
	FCC	"PULB"	* $4e
	FCC	"ROLA"	* $4f
	FCC	"ROLB"	* $50
	FCC	"ROL "	* $51
	FCC	"RORA"	* $52
	FCC	"RORB"	* $53
	FCC	"ROR "	* $54
	FCC	"RTI "	* $55
	FCC	"RTS "	* $56
	FCC	"SBA "	* $57
	FCC	"SBCA"	* $58
	FCC	"SBCB"	* $59
	FCC	"SEC "	* $5a
	FCC	"SEI "	* $5b
	FCC	"SEV "	* $5c
	FCC	"STAA"	* $5d
	FCC	"STAB"	* $5e
	FCC	"STS "	* $5f
	FCC	"STX "	* $60
	FCC	"SUBA"	* $61
	FCC	"SUBB"	* $62
	FCC	"SWI "	* $63
	FCC	"TAB "	* $64
	FCC	"TAP "	* $65
	FCC	"TBA "	* $66
	FCC	"TPA "	* $67
	FCC	"TSTA"	* $68
	FCC	"TSTB"	* $69
	FCC	"TST "	* $6a
	FCC	"TSX "	* $6b
	FCC	"TXS "	* $6c
	FCC	"WAI "	* $6d
	FCC	"EQU "	* $6e (pseudo-op)
	FCC	"ORG "	* $6f (pseudo-op)
	FCC	"FCB "	* $70 (pseudo-op)
	FCC	"FCC "	* $71 (pseudo-op)
	FCC	"FDB "	* $72 (pseudo-op)
mneend
opcode
	FCB	0,0	* 00
	FCB	NOP,inh	* 01
	FCB	0,0	* 02
	FCB	0,0	* 03
	FCB	0,0	* 04
	FCB	0,0	* 05
	FCB	TAP,inh	* 06
	FCB	TPA,inh	* 07
	FCB	INX,inh	* 08
	FCB	DEX,inh	* 09
	FCB	CLV,inh	* 0a
	FCB	SEV,inh	* 0b
	FCB	CLC,inh	* 0c
	FCB	SEC,inh	* 0d
	FCB	CLI,inh	* 0e
	FCB	SEI,inh	* 0f
	FCB	SBA,inh	* 10
	FCB	CBA,inh	* 11
	FCB	0,0	* 12
	FCB	0,0	* 13
	FCB	0,0	* 14
	FCB	0,0	* 15
	FCB	TAB,inh	* 16
	FCB	TBA,inh	* 17
	FCB	0,0	* 18
	FCB	DAA,inh	* 19
	FCB	0,0	* 1a
	FCB	ABA,inh	* 1b
	FCB	0,0	* 1c
	FCB	0,0	* 1d
	FCB	0,0	* 1e
	FCB	0,0	* 1f
	FCB	BRA,rel	* 20
	FCB	0,0	* 21
	FCB	BHI,rel	* 22
	FCB	BLS,rel	* 23
	FCB	BCC,rel	* 24
	FCB	BCS,rel	* 25
	FCB	BNE,rel	* 26
	FCB	BEQ,rel	* 27
	FCB	BVC,rel	* 28
	FCB	BVS,rel	* 29
	FCB	BPL,rel	* 2a
	FCB	BMI,rel	* 2b
	FCB	BGE,rel	* 2c
	FCB	BLT,rel	* 2d
	FCB	BGT,rel	* 2e
	FCB	BLE,rel	* 2f
	FCB	TSX,inh	* 30
	FCB	INS,inh	* 31
	FCB	PULA,acc	* 32
	FCB	PULB,acc	* 33
	FCB	DES,inh	* 34
	FCB	TXS,inh	* 35
	FCB	PSHA,acc	* 36
	FCB	PSHB,acc	* 37
	FCB	0,0	* 38
	FCB	RTS,inh	* 39
	FCB	0,0	* 3a
	FCB	RTI,inh	* 3b
	FCB	0,0	* 3c
	FCB	0,0	* 3d
	FCB	WAI,inh	* 3e
	FCB	SWI,inh	* 3f
	FCB	NEGA,acc	* 40
	FCB	0,0	* 41
	FCB	0,0	* 42
	FCB	COMA,acc	* 43
	FCB	LSRA,acc	* 44
	FCB	0,0	* 45
	FCB	RORA,acc	* 46
	FCB	ASRA,acc	* 47
	FCB	ASLA,acc	* 48
	FCB	ROLA,acc	* 49
	FCB	DECA,acc	* 4a
	FCB	0,0	* 4b
	FCB	INCA,acc	* 4c
	FCB	TSTA,acc	* 4d
	FCB	0,0	* 4e
	FCB	CLRA,acc	* 4f
	FCB	NEGB,acc	* 50
	FCB	0,0	* 51
	FCB	0,0	* 52
	FCB	COMB,acc	* 53
	FCB	LSRB,acc	* 54
	FCB	0,0	* 55
	FCB	RORB,acc	* 56
	FCB	ASRB,acc	* 57
	FCB	ASLB,acc	* 58
	FCB	ROLB,acc	* 59
	FCB	DECB,acc	* 5a
	FCB	0,0	* 5b
	FCB	INCB,acc	* 5c
	FCB	TSTB,acc	* 5d
	FCB	0,0	* 5e
	FCB	CLRB,acc	* 5f
	FCB	NEG,idx	* 60
	FCB	0,0	* 61
	FCB	0,0	* 62
	FCB	COM,idx	* 63
	FCB	LSR,idx	* 64
	FCB	0,0	* 65
	FCB	ROR,idx	* 66
	FCB	ASR,idx	* 67
	FCB	ASL,idx	* 68
	FCB	ROL,idx	* 69
	FCB	DEC,idx	* 6a
	FCB	0,0	* 6b
	FCB	INC,idx	* 6c
	FCB	TST,idx	* 6d
	FCB	JMP,idx	* 6e
	FCB	CLR,idx	* 6f
	FCB	NEG,ext	* 70
	FCB	0,0	* 71
	FCB	0,0	* 72
	FCB	COM,ext	* 73
	FCB	LSR,ext	* 74
	FCB	0,0	* 75
	FCB	ROR,ext	* 76
	FCB	ASR,ext	* 77
	FCB	ASL,ext	* 78
	FCB	ROL,ext	* 79
	FCB	DEC,ext	* 7a
	FCB	0,0	* 7b
	FCB	INC,ext	* 7c
	FCB	TST,ext	* 7d
	FCB	JMP,ext	* 7e
	FCB	CLR,ext	* 7f
	FCB	SUBA,imm	* 80
	FCB	CMPA,imm	* 81
	FCB	SBCA,imm	* 82
	FCB	0,0	* 83
	FCB	ANDA,imm	* 84
	FCB	BITA,imm	* 85
	FCB	LDAA,imm	* 86
	FCB	0,0	* 87
	FCB	EORA,imm	* 88
	FCB	ADCA,imm	* 89
	FCB	ORAA,imm	* 8a
	FCB	ADDA,imm	* 8b
	FCB	CPX,imm16	* 8c
	FCB	BSR,rel	* 8d
	FCB	LDS,imm16	* 8e
	FCB	0,0	* 8f
	FCB	SUBA,dir	* 90
	FCB	CMPA,dir	* 91
	FCB	SBCA,dir	* 92
	FCB	0,0	* 93
	FCB	ANDA,dir	* 94
	FCB	BITA,dir	* 95
	FCB	LDAA,dir	* 96
	FCB	STAA,dir	* 97
	FCB	EORA,dir	* 98
	FCB	ADCA,dir	* 99
	FCB	ORAA,dir	* 9a
	FCB	ADDA,dir	* 9b
	FCB	CPX,dir	* 9c
	FCB	0,0	* 9d
	FCB	LDS,dir	* 9e
	FCB	STS,dir	* 9f
	FCB	SUBA,idx	* a0
	FCB	CMPA,idx	* a1
	FCB	SBCA,idx	* a2
	FCB	0,0	* a3
	FCB	ANDA,idx	* a4
	FCB	BITA,idx	* a5
	FCB	LDAA,idx	* a6
	FCB	STAA,idx	* a7
	FCB	EORA,idx	* a8
	FCB	ADCA,idx	* a9
	FCB	ORAA,idx	* aa
	FCB	ADDA,idx	* ab
	FCB	CPX,idx	* ac
	FCB	JSR,idx	* ad
	FCB	LDS,idx	* ae
	FCB	STS,idx	* af
	FCB	SUBA,ext	* b0
	FCB	CMPA,ext	* b1
	FCB	SBCA,ext	* b2
	FCB	0,0	* b3
	FCB	ANDA,ext	* b4
	FCB	BITA,ext	* b5
	FCB	LDAA,ext	* b6
	FCB	STAA,ext	* b7
	FCB	EORA,ext	* b8
	FCB	ADCA,ext	* b9
	FCB	ORAA,ext	* ba
	FCB	ADDA,ext	* bb
	FCB	CPX,ext	* bc
	FCB	JSR,ext	* bd
	FCB	LDS,ext	* be
	FCB	STS,ext	* bf
	FCB	SUBB,imm	* c0
	FCB	CMPB,imm	* c1
	FCB	SBCB,imm	* c2
	FCB	0,0	* c3
	FCB	ANDB,imm	* c4
	FCB	BITB,imm	* c5
	FCB	LDAB,imm	* c6
	FCB	0,0	* c7
	FCB	EORB,imm	* c8
	FCB	ADCB,imm	* c9
	FCB	ORAB,imm	* ca
	FCB	ADDB,imm	* cb
	FCB	0,0	* cc
	FCB	0,0	* cd
	FCB	LDX,imm16	* ce
	FCB	0,0	* cf
	FCB	SUBB,dir	* d0
	FCB	CMPB,dir	* d1
	FCB	SBCB,dir	* d2
	FCB	0,0	* d3
	FCB	ANDB,dir	* d4
	FCB	BITB,dir	* d5
	FCB	LDAB,dir	* d6
	FCB	STAB,dir	* d7
	FCB	EORB,dir	* d8
	FCB	ADCB,dir	* d9
	FCB	ORAB,dir	* da
	FCB	ADDB,dir	* db
	FCB	0,0	* dc
	FCB	0,0	* dd
	FCB	LDX,dir	* de
	FCB	STX,dir	* df
	FCB	SUBB,idx	* e0
	FCB	CMPB,idx	* e1
	FCB	SBCB,idx	* e2
	FCB	0,0	* e3
	FCB	ANDB,idx	* e4
	FCB	BITB,idx	* e5
	FCB	LDAB,idx	* e6
	FCB	STAB,idx	* e7
	FCB	EORB,idx	* e8
	FCB	ADCB,idx	* e9
	FCB	ORAB,idx	* ea
	FCB	ADDB,idx	* eb
	FCB	0,0	* ec
	FCB	0,0	* ed
	FCB	LDX,idx	* ee
	FCB	STX,idx	* ef
	FCB	SUBB,ext	* f0
	FCB	CMPB,ext	* f1
	FCB	SBCB,ext	* f2
	FCB	0,0	* f3
	FCB	ANDB,ext	* f4
	FCB	BITB,ext	* f5
	FCB	LDAB,ext	* f6
	FCB	STAB,ext	* f7
	FCB	EORB,ext	* f8
	FCB	ADCB,ext	* f9
	FCB	ORAB,ext	* fa
	FCB	ADDB,ext	* fb
	FCB	0,0	* fc
	FCB	0,0	* fd
	FCB	LDX,ext	* fe
	FCB	STX,ext	* ff
opcend
