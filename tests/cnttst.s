**********************************************************************
* Line Continuation Test
*  Tests for backslash line continuation feature
**********************************************************************

* Test 1: Simple continuation in operand field
T1_LBL	LDAA	#$10 \
	ADDB	#$20

* Test 2: Continuation in mnemonic field
	LDX	#$200 \
	STAA	0,X

* Test 3: Multiple continuations
	LDAA	#$01 \
	ADDB	#$02 \
	STAA	$300

* Test 4: Backslash in quoted string (should be literal)
	FCC	"test\"literal"

* Test 5: Continuation in comment field
	LDAA	#$10 * comment continues \
	ADDB	#$20

* Expected behavior:
* - Tests 1-3: Lines should continue without terminating
* - Test 4: Backslash in quotes should be literal, not continuation
* - Test 5: Comment should continue (not tested by assembler, but stored)
