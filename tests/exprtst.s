**********************************************************************
*  exprtst.s
*  asm68
*
*  Created by Gemini on 12/6/25.
*
* Verifies correct arithmetic, L-R evaluation, and checks for chaining flaws.
* **NOTE 14-CHARACTER OPERAND LIMIT**
**********************************************************************

* --- ISOLATED SUB-EXPRESSION TESTS (FDB) ---

* T05 Isolation (30000+2000-3000 -> 15 chars, cannot be run)
* We use a sub-14 char version for testing: 3000+200-300
ISO_C05_1	FDB	30000+2000	* Chars: 10. Expected: 32000 ($7D00)
ISO_C05_2	FDB	32000-3000	* Chars: 10. Expected: 29000 ($7148)

* T07 Isolation
ISO_C07_1	FDB	5000/2	* Chars: 6. Expected: 2500 ($09C4)
ISO_C07_2	FDB	2500*-5	* Chars: 7. Expected: -12500 ($CF2C)
ISO_C07_3	FDB	-12500/-2	* Chars: 9. Expected: 6250 ($186A)

* T08 Isolation
ISO_C08_1	FDB	65535/2	* Chars: 7. Expected: -1/2=0 ($0000)
ISO_C08_2	FDB	32767*2	* Chars: 7. Expected: 65534 ($FFFE)
ISO_C08_3	FDB	65534+1	* Chars: 7. Expected: 65535 ($FFFF)

* --- 8-bit Combined Expressions (FCB) ---

* T01: Pos + Pos * Neg / Neg
TESTC01	FCB	10+5*-2/-3	* Chars: 10. Expected: 10 ($0A)
* T02: Division with Subtraction
TESTC02	FCB	100/10*2-2	* Chars: 10. Expected: 18 ($12)
* T03: Mixed Signs with Truncation
TESTC03	FCB	-5*10/-3+1	* Chars: 10. Expected: 17 ($11)
* T04: Complex Negative Truncation
TESTC04	FCB	100*-1/-2+5	* Chars: 12. Expected: 55 ($37)

* --- 16-bit Combined Expressions (FDB) ---

* T05: Addition and Subtraction of Large Numbers
TESTC05	FDB	30000+2000-300	* Chars: 14. Expected: 31700 ($7BD4)
* T06: Multiplication and Subtraction
TESTC06	FDB	10000*3-1000	* Chars: 12. Expected: 29000 ($7148)
* T07: Chained Division/Multiplication
TESTC07	FDB	5000/2*-5/-2	* Chars: 12. Expected: 6250 ($186A)
* T08: Extreme Truncation Check
TESTC08	FDB	65535/2*2+1	* Chars: 11. Expected: 1 ($0001)
* T09: Chaining
TESTC09	FDB	8000+1000-1000	* Chars: 14. Expected: 8000 ($1F40)
