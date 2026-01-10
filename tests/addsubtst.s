**********************************************************************
*  addsubtst.s
*  asm68
*
*  Created by Gemini on 12/6/25.
**********************************************************************

* --- COMPREHENSIVE ADDITION & SUBTRACTION TESTS ---
* Verifies signed 8-bit and 16-bit arithmetic.
* Tests use FCB/FDB to emit results for verification.

* --- Test Constants ---
BASEAD	EQU	$1000	; Base address for address calculation
MAX8S	EQU	127	; Max Signed 8-bit positive
MIN8S	EQU	-128	; Max Signed 8-bit negative
MAX16U	EQU	$FFFF	; Max Unsigned 16-bit
MAX16S	EQU	32767	; Max Signed 16-bit positive

* --- 8-bit Addition/Subtraction Tests (FCB) ---
* All results should fit within an 8-bit signed value (-128 to 127).

; T01: Basic Positive Addition (10 + 20 = 30)
ADD_A1	FCB	10+20

; T02: Negative + Positive (-5 + 10 = 5)
ADD_A2	FCB	-5+10

; T03: Positive + Negative (20 + (-10) = 10)
ADD_A3	FCB	20+-10

; T04: Boundary Overflow (127 + 1 = 128 = -128)
; The assembler uses 16-bit math internally, then truncates to 8-bit.
; 128 decimal becomes $80, which is -128 in 2's complement.
ADD_A4	FCB	MAX8S+1

; T05: Basic Subtraction (50 - 20 = 30)
SUB_S1	FCB	50-20

; T06: Subtraction resulting in Negative (10 - 50 = -40)
SUB_S2	FCB	10-50

; T07: Double Negative Subtraction (-5 - 10 = -15)
SUB_S3	FCB	-5-10

; T08: Subtraction resulting in Max Positive (127 - (-1) = 128 = -128)
; 128 decimal becomes $80, which overflows to -128.
SUB_S4	FCB	MAX8S--1

; T09: Underflow (-128 - 1 = -129 = 127)
; -129 decimal becomes $7F, which is 127 in 2's complement.
SUB_S5	FCB	MIN8S-1

* --- 16-bit Addition/Subtraction Tests (FDB) ---
* These tests verify correct 16-bit signed math.

; T10: Basic 16-bit Addition (1000 + 2000 = 3000 = $0BB8)
ADD_W1	FDB	1000+2000

; T11: Max Positive + 1 (32767 + 1 = 32768 = -32768)
; Result $8000 (MSB set, 2's complement overflow).
ADD_W2	FDB	MAX16S+1

; T12: Max Unsigned - 1 ($FFFF - 1 = $FFFE)
SUB_W1	FDB	MAX16U-1

; T13: Subtraction resulting in Negative (100 - 30000 = -29900 = $8B34)
SUB_W2	FDB	100-30000

* --- Address Calculation Tests (FDB) ---
; These verify address arithmetic, which uses 16-bit math.

; T14: Address Addition (BASEAD + 100 = $1064)
ADDR_A1	FDB	BASEAD+100

; T15: Address Subtraction (BASEAD + 100 - 50 = $1032)
ADDR_S1	FDB	BASEAD+100-50

; T16: Address Wrap-around ($FFFF + 1 = $0000)
ADDR_W1	FDB	MAX16U+1

* --- 16-bit Subtraction Boundary Test (FDB) ---

; T17: Subtraction resulting in Max Negative (-32767 - 1 = -32768)
; Expected result is the 16-bit minimum signed integer ($8000)
SUB_W3	FDB	-32767-1
