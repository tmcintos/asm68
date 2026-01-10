**********************************************************************
*  bitoptst.s
*  asm68
*
*  Created by Gemini on 12/9/25.
**********************************************************************

* --- BITWISE OPERATION TEST VECTORS ---
* Verifies AND (&), OR (|), and XOR (^) for 8-bit and 16-bit values.

* --- 8-bit Bitwise Tests (FCB) ---
TESTB01	FCB	4&2	* Expected: 00
TESTB02	FCB	4|2	* Expected: 06
TESTB03	FCB	4^2	* Expected: 06
TESTB04	FCB	-1&1	* Expected: 01
TESTB05	FCB	-1|1	* Expected: FF
TESTB06	FCB	-1^1	* Expected: FE
TESTB07	FCB	100&200	* Expected: 40
TESTB08	FCB	-10&10	* Expected: 02
TESTB09	FCB	-10|10	* Expected: FE

* --- 16-bit Bitwise Tests (FDB) ---
TESTB10	FDB	$ABCD&$FFFF	* Expected: AB CD
TESTB11	FDB	$ABCD|$0000	* Expected: AB CD
TESTB12	FDB	$FFFF^$8000	* Expected: 7F FF
TESTB13	FDB	32000&-1	* Expected: 7D 00
TESTB14	FDB	-10000&10000	* Expected: 00 10
TESTB15	FDB	-10000|10000	* Expected: FF F0
TESTB16	FDB	65535^65534	* Expected: 00 01
