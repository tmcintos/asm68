**********************************************************************
*  divtst.s
*  asm68
*
*  Created by Gemini on 12/6/25.
**********************************************************************

* --- COMPREHENSIVE DIVISION EXPRESSION TESTS ---
* Results verify 16-bit unsigned integer division and floor truncation.
* Compatible with modern host-system behavior for 16-bit address arithmetic.

MAX8S	EQU	127	; Max Signed 8-bit positive
MIN8S	EQU	-128	; Max Signed 8-bit negative
MAX16S	EQU	32767	; Max Signed 16-bit positive

* --- 8-bit Division Tests (FCB) ---
* Results verify truncation towards zero.

* --- 8-bit Division Result Tests (FCB) ---

; T01: Basic Division (100 / 10 = 10)
DIV_A1	FCB	100/10		* Expected: $0A (10)

; T02: Truncation (100 / 7 = 14)
DIV_A2	FCB	100/7		* Expected: $0E (14)

; T03: Division by 1
DIV_A3	FCB	127/1		* Expected: $7F (127)

; T04: "High Byte" Extraction (Address $E3CB / $100)
; This now matches modern 32/64-bit host behavior.
DIV_A4	FCB	$E3CB/$100	* Expected: $E3 (227)

; T05: Large Unsigned Dividend (-100 as $FF9C / 10)
; $FF9C (65436) / 10 = 6543
DIV_A5	FCB	-100/10		* Expected: $6F (LSB of 6543) - Note: result > 255

; T06: Unsigned Wrap-around (-100 / -10 as $FF9C / $FFF6)
; 65436 / 65526 = 0
DIV_A6	FCB	-100/-10	* Expected: $00

* --- 16-bit Division Result Tests (FDB) ---

; T10: Basic 16-bit Division (5000 / 5 = 1000)
DIV_W1	FDB	5000/5		* Expected: $03E8 (1000)

; T11: Max Unsigned Range (65535 / 2)
DIV_W2	FDB	65535/2		* Expected: $7FFF (32767)

; T12: Large Dividend (Address $C000 / 4)
DIV_W3	FDB	$C000/4		* Expected: $3000 (12288)

; T13: Underflow Check (1 / 256 = 0)
DIV_W4	FDB	1/256		* Expected: $0000

; --- ERROR TEST ---
; T14: Division by Zero (Verify assembler halt/error trap)
DIV_ERR	FDB	1/0
