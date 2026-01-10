**********************************************************************
*  multst.s
*  asm68
*
*  Created by Gemini on 12/6/25.
**********************************************************************

* --- COMPREHENSIVE SIGNED MULTIPLICATION TESTS ---
* Verifies 16-bit signed multiplication (FDB) and 8-bit expression check (FCB).
* Ensures correct 2's complement handling for negative products.

* --- Test Constants ---
BASE	EQU	$1000	; Define symbolic address
MAX16S	EQU	32767	; Max Signed 16-bit positive
MIN16S	EQU	-32768	; Min Signed 16-bit negative

* --- 16-bit Signed Multiplication Tests (FDB) ---

* T1: Pos x Pos (Base Check)
T1FDB	FDB	10*20	* 200 = $00C8

* T2: Pos x Neg (Simple)
T2FDB	FDB	10*-20	* -200 = $FF38

* T3: Neg x Pos (Simple)
T3FDB	FDB	-10*20	* -200 = $FF38

* T4: Neg x Neg (Simple)
T4FDB	FDB	-10*-20	* 200 = $00C8

* T5: Pos x Neg (Large Result)
T5FDB	FDB	100*-100	* -10000 = $D8F0

* T6: Neg x Pos (Boundary)
T6FDB	FDB	MIN16S*1	* -32768 * 1 = -32768 = $8000

* T7: Neg x Neg (Boundary Check)
T7FDB	FDB	-128*-256	* 32768. 16-bit truncation of $00008000 is $8000.
* Expected result is the lower 16 bits of the 32-bit product: $8000

* T8: Pos x Neg (Extreme Boundary)
T8FDB	FDB	127*-256	* -32512 = $8100

* --- 8-bit Signed Multiplication Check (FCB) ---
* These tests ensure the sign wrapper does not break 8-bit (FCB) calculation.

* T9: Pos x Neg (8-bit result)
TEST9	FCB	10*-10	* -100 = $9C

* T10: Neg x Neg (8-bit result)
TESTA	FCB	-10*-10	* 100 = $64
