**********************************************************************
*  modtst.s
*  asm68
*
*  Created by Gemini on 12/8/25.
**********************************************************************

* --- UNSIGNED MODULO TEST VECTORS ---
* Treats all operands as 16-bit unsigned integers ($0 to $FFFF).

* --- 8-bit Modulo Result Tests (FCB) ---

* T01: Basic Modulo (10 % 3 = 1)
TESTM01	FCB	10%3		* Expected: $01
* T02: Small % Large Unsigned (10 % -3)
* 10 / 65533 = 0 R 10.
TESTM02	FCB	10%-3		* Expected: $0A (10)
* T03: Large Unsigned % Small (-10 % 3)
* 65526 / 3 = 21842 R 0.
TESTM03	FCB	-10%3		* Expected: $00
* T04: Large % Large (-10 % -3)
* 65526 / 65533 = 0 R 65526.
TESTM04	FCB	-10%-3		* Expected: $F6 (LSB of 65526)
* T05: Modulo Zero
TESTM05	FCB	5%5		* Expected: $00
* T06: 25 % 4 = 1
TESTM06	FCB	25%4		* Expected: $01
* T07: -5 % 100 (65531 % 100)
* 65531 / 100 = 655 R 31.
TESTM07	FCB	-5%100		* Expected: $1F (31)

* --- 16-bit Modulo Result Tests (FDB) ---

* T08: 32000 % 1000 = 0
TESTM08	FDB	32000%1000	* Expected: $0000
* T09: -32000 % 1000 (33536 % 1000)
* 33536 / 1000 = 33 R 536.
TESTM09	FDB	-32000%1000	* Expected: $0218 (536)
* T10: Max Pos % Small Pos
TESTM10	FDB	32767%32766	* Expected: $0001
* T11: -32768 % 10 (32768 % 10)
* 32768 / 10 = 3276 R 8.
TESTM11	FDB	-32768%10	* Expected: $0008
* T12: -32768 % -32767 (32768 % 32769)
* 32768 / 32769 = 0 R 32768.
TESTM12	FDB	-32768%-32767	* Expected: $8000
* T13: Critical Safety Test
DIV_MOD_ZERO FDB 10%0		* Expected: Error/Halt Assembly
