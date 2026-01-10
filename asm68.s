**********************************************************************
* asm68.s
*
* Created by Tim McIntosh on 10/28/2025
**********************************************************************

**********************************************************************
* M6800 byte order is big-endian.
* Calling convention:
*  First 8-bit argument/return value passed in ACC A
*  Second 8-bit argument/return value passed in ACC B
*  16-bit argument/return value may be passed AB (MSB in A)
*   OR
*  16-bit argument/return value may be passed in X
*  P: Caller saved/restored (volatile)
*  A: Caller saved/restored (volatile)
*  B: Callee saved/restored (nonvolatile)
*  X: Callee saved/restored (nonvolatile)
**********************************************************************

**********************************************************************
* main program
**********************************************************************
main
	lds	#XSTKTP	* Init X stack
	sts	xstksp
	lds	#DSTKTP	* Init data stack
	sts	datasp
	lds	#STKTOP	* Init call stack
	jsr	newline
	ldx	#hello
	bsr	puts
	ldx	#jmpbuf	* set up error handler
	jsr	setjmp	* on error, will return here
	bsr	docmd
exit
	ldx	#bye
	bsr	puts
	jmp	MON

**********************************************************************
* aserx(code) - abort with assembler error code (A)
**********************************************************************
aserx
	psha		* save error code
	jsr	prlnum	* print line number
	ldaa	#':'
	jsr	ECHO	* print colon
	jsr	outsp	* print space
	ldx	#error
	bsr	puts	* print "error "
	pula
	jsr	PRBYTE
	jsr	newline
	ldx	#jmpbuf	* lngjmp(jmpbuf, 1+code)
	pulb
	incb
	clra
	jmp	lngjmp	* abnormal exit

**********************************************************************
* puts - Print nul-terminated string pointed to by X (not preserved).
**********************************************************************
puts
	psha		* save A
.putch	ldaa	,x
	beq	.puts
	inx
	jsr	ECHO
	bra	.putch
*--------------------------------------------------------------------
.puts	pula		* restore A
	rts

**********************************************************************
* docmd - command interpreter loop
**********************************************************************
docmd
	ldaa	#PROMPT
	jsr	ECHO
	jsr	outsp
	jsr	getc	* Read command character
	bsr	lowc	* Convert to lowercase
	tab		* Save command in ACC B
	jsr	newline
	cmpb	#'$'
	beq	.docmd
	ldx	#cmds-2	* prepare to traverse cmdtbl
.nxcmd	inx		* X = next entry
	inx
	ldaa	,x	* ACC A = next command in table
	beq	docmd	* if NUL, read next command
	inx		* X = address field
	cba		* command matches?
	bne	.nxcmd	* if no, loop
	ldx	,x	* else, load command routine address
	jsr	,x	* and call it
	bra	docmd	* then read next command
*--------------------------------------------------------------------
.docmd	rts

**********************************************************************
* lowc - Convert character in ACC A to lowercase and return it
**********************************************************************
lowc
	cmpa	#'A'
	blo	.lowc
	cmpa	#'Z'
	bhi	.lowc
	oraa	#$20
.lowc	rts

**********************************************************************
* lsrc - L (list source) command
**********************************************************************
lsrc
* initialize current line = 0
	ldx	#-1	* init line number to -1
	stx	line
	ldx	#srcbuf-1	* let X track current source position
.lxtln	inx
	stx	linptr	* save start of current line
	ldx	line	* 16-bit increment of line number
	inx
	stx	line
	ldx	linptr	* restore X
	bsr	prlnum	* print line # followed by space
.lslin	clr	column	* reset column
	ldaa	,x	* read first character of line
	beq	.lsrc	* NUL at start of line = end of source
	cmpa	#EMPTY	* blank line?
	bne	.lntbl	* skip if not blank line
.ltoel	inx		* consume character
	ldaa	,x	* read next character
	bne	.ltoel	* loop until end of line
	bra	.lgonl	* go to next line
*--------------------------------------------------------------------
.lntbl	ldaa	#fields/$100	* fieldptr = fields
	staa	fldptr
	ldaa	#fields%$100
	staa	fldptr+1
.lxtfd
	stx	xsave	* read next field length into ACC B
	ldx	fldptr
	ldab	,x
	ldx	xsave	* restore X
.lxtch	ldaa	,x	* read next character of line
	bmi	.detok	* if token, see below
	bne	.nteol	* check for end of line (NUL)
.lgonl	bsr	newline
	bra	.lxtln
*--------------------------------------------------------------------
.detok	inx		* consume token
	stx	linptr	* save X
	anda	#$7f	* clear bit 7 of token
	jsr	idxmne	* get mnemonic name in X
	jsr	outmne	* print mnemonic at X
	ldx	linptr	* restore X
	subb	#4	* reduce field length
	ldaa	column
	adda	#4	* column += 4
	staa	column
	bra	.lxtch
*--------------------------------------------------------------------
.nteol	bsr	iscom	* check for comment character
	bne	.lntcm	* if not comment, continue below
	bsr	lincom	* else, set up for line comment
.lntcm	cmpa	#FS	* check for end of field (FS)
	beq	.gotfs
	decb		* reduce field length
	jsr	ECHO	* print char
	inc	column	* column++
	inx		* consume character
	bra	.lxtch
*--------------------------------------------------------------------
.gotfs	inx		* consume field separator
	tstb		* check field length
	beq	.lnxfd	* at end, move to next field
.lstfd	bsr	outsp	* print spaces until end is reached
	inc	column	* column++
	decb
	beq	.lnxfd	* at end, move to next field
	bra	.lstfd
*--------------------------------------------------------------------
.lnxfd	bsr	outsp
	bsr	fldinc	* advance to next field
	bra	.lxtfd
*--------------------------------------------------------------------
.lsrc	bra	newline	* call newline and return

**********************************************************************
* prlnum - print current line # followed by space
**********************************************************************
prlnum
	ldaa	line
	jsr	PRHEX
	ldaa	line+1
	jsr	PRBYTE
	bra	outsp	* call outsp and return

**********************************************************************
* fldinc - increment fldptr
**********************************************************************
fldinc
	inc	fldptr+1	* increment low byte of fldptr
	bne	.fiend	* check for rollover
	inc	fldptr	* increment upper byte if needed
.fiend	rts

**********************************************************************
* lincom - set up for line comment, return field length in ACC B
* 	 - Note: preserves ACC A
**********************************************************************
lincom
	stx	xsave	* save X
	ldx	#fields+COMENT	* advance fldptr to comment field
	stx	fldptr
	ldx	xsave	* restore X
	ldab	#LINLEN	* update field width
	subb	column	* taking current column into account
	rts

**********************************************************************
* iscom - test for comment character (either * or ; is allowed)
**********************************************************************
iscom
	cmpa	#'*'
	beq	.iscom
	cmpa	#';'
.iscom	rts

**********************************************************************
* outsp - Print a space
**********************************************************************
outsp
	ldaa	#' '
	jmp	ECHO	* call ECHO and return

**********************************************************************
* newline - Print newline sequence. Return newline character in ACC A.
**********************************************************************
newline
	ldaa	#CR
	jmp	ECHO	* call ECHO and return

**********************************************************************
* isend - Compare input char in ACC A to end of message (EOT, ESC).
*  Returns character in ACC A, with flags updated by comparison.
**********************************************************************
isend
	cmpa	#ESC
	beq	.isend
	cmpa	#EOT
.isend	rts

**********************************************************************
* nsrc - N (new source) command
**********************************************************************
.nsrc	ldaa	#NUL	* store terminating NUL,NUL
	staa	,x
	inx
	staa	,x
	bra	newline	* call newline and return
*--------------------------------------------------------------------
nsrc
	clr	qotflg	* clear quote flag
* initialize current line = 0
	ldx	#-1	* init line number to -1
	stx	line
	ldx	#srcbuf	* let X track current source position
.nxtln
	clr	curins	* clear current mnemonic
	stx	xsave	* save X
	ldx	line	* 16-bit increment of line number
	inx
	stx	line
	ldx	xsave	* restore X
	bsr	prlnum	* print line # followed by space
.rdlin	clr	column	* reset column
* read fields
	ldaa	#fields/$100	* fieldptr = fields
	staa	fldptr
	ldaa	#fields%$100
	staa	fldptr+1
.rdfld
	stx	linptr	* save X (start of current field)
	ldx	fldptr	* read next field length into ACC B
	ldab	,x
	ldx	linptr	* restore X
.nxtch	jsr	getch	* read char without echo
	bsr	isend	* check for ESC or EOT (end of input)
	beq	.nsrc	* return
	bsr	iscom	* check for comment character
	bne	.ntcom	* if not comment, continue below
	bsr	lincom	* set up for line comment
.ntcom	cmpa	#CR	* end of line?
	bne	.notcr	* skip if not end of line
	tst	column	* blank line?
	bne	.ntblk	* skip if not blank line
	ldaa	#EMPTY	* store blank line marker
	staa	,x
	inx
.ntblk	ldaa	#NUL	* ACC A = end-of-line marker (NUL)
	staa	,x	* store here & pass to tokmne below
	inx
	bsr	tokmne	* tokenize mnemonic field if needed
	bsr	newline	* output newline
	bra	.nxtln	* read next input line
*--------------------------------------------------------------------
.notcr	cmpa	#BSIN
	bne	.notbs	* if BS, delete typed characters...
	inc	column	* column++
.bkspc	dec	column	* column--
	beq	.rdlin	* already at start of line?
	ldaa	#BS
	jsr	ECHO
	dex
	bra	.bkspc
*--------------------------------------------------------------------
.notbs
* XXX this doesn't work because same condition occurs at end of field:
*	tstb		* check for last field
*	beq	.nxtch	* drop character if last field
	bsr	fldsp	* check for field separator
	bne	.notfs
	ldaa	#FS	* got field separator, store FS
	staa	,x
	inx
	tstb		* check field length
	beq	.advfd	* at end, move to next field
.padfd	jsr	outsp	* pad with space until end is reached
	inc	column	* column++
	decb
	beq	.advfd	* at end, move to next field
	bra	.padfd
*--------------------------------------------------------------------
.notfs	cmpa	#'''
	bne	.notqc	* quote character?
	com	qotflg	* if yes, toggle quotflg
.notqc	tstb		* check field length
	beq	.nxtch	* drop character
	staa	,x	* store character
	inx
	decb		* reduce field length
	jsr	ECHO	* print char
	inc	column	* column++
	bra	.nxtch
*--------------------------------------------------------------------
.advfd	jsr	outsp
	ldaa	#FS	* field terminator to store
	bsr	tokmne	* tokenize mnemonic field if needed
.nxfld	inc	column	* column++
	jsr	fldinc	* advance to next field
	bra	.rdfld
*--------------------------------------------------------------------

**********************************************************************
* fldsp - Compare input char in ACC A to field separator.
*  Returns character in ACC A, with flags updated by comparison.
**********************************************************************
fldsp
	tst	qotflg	* previous character was quote?
	beq	.ckfcc	* if no, proceed below
	clr	qotflg	* else, clear qotflg
	bra	.nospc	* and allow space
*--------------------------------------------------------------------
.ckfcc	psha		* save A
	ldaa	#FCC
	cmpa	curins	* current instruction is FCC?
	pula		* restore A
	beq	.nospc	* allow spaces in FCC
	psha		* save A
	bsr	fldidx	* get current field index
	cmpa	#COMENT	* compare to comment field position
	pula		* restore A
	bhs	.nospc	* allow spaces in comments
	cmpa	#' '
	beq	.fldsp
.nospc	cmpa	#HT
.fldsp	rts

**********************************************************************
* fldidx - Returns current field index in ACC A
**********************************************************************
fldidx
	ldaa	fldptr+1	* load field pointer low byte in B
	suba	#fields	* subtract base to get index
	rts

**********************************************************************
* tokmne(eof) - if in mnemonic field, tokenize mnemonic at linptr
*	- ACC A = end-of-field terminator (FS/NUL)
*	- return end of line in X
*	- ACC B NOT preserved
*	- mnemonic stored in curins
**********************************************************************
tokmne
	psha		* save argument/result
	bsr	fldidx	* get current field index in ACC A
	cmpa	#MNEMON	* mnemonic field?
	pula		* restore argument/result
	bne	.tmend	* if no, return
	psha		* save argument
* attempt to recognize mnemonic:
	ldx	#mnemon	* reset mnemonic table pointer
	stx	mneptr
.asmne
	ldab	#4	* ACC B - track mnemonic chars left to consume
	ldx	linptr	* roll back to start of mnemonic field
	ldaa	,x	* read first source char
	jsr	iseof	* end of field/line (FS/NUL)?
	beq	.tmemt	* if empty field, exit
.asmlp	ldaa	,x	* read next source char
	jsr	uprc	* convert to uppercase
	stx	xsave	* save X
	ldx	mneptr	* X = mneptr
	cmpa	,x	* compare source char to next mnemonic char
	psha		* save source char on stack
	tpa		* save flags around next ldx
	staa	psave
	ldx	xsave	* restore X
	ldaa	psave	* restore flags with comparison state
	tap
	pula		* restore source char from stack
	bne	.asneq	* branch if source != mnemonic
* matched, consume character
	inx		* increment source pointer
	bsr	mneinc	* increment mneptr and decrement ACC B
	tstb		* check for end of nmemonic
	bne	.asmlp	* loop until length limit hit
	ldaa	,x	* hit max length - read next source char (should be FS/NUL)
* match conditions:
*	- source char = FS/NUL - else either mismatch or src mne too long (ACC B=0)
*	- (ACC B = 0) OR (ACC B = 1 AND next mnemonic char is ' ')
.asneq	jsr	iseof	* test for end of field/line [FS or NUL (EOL)]
	bne	.ascom	* if not at end, check for overrun/mismatch
	cmpb	#1	* else, check remaining mnemonic length
	bhi	.asnxm	* ACC B > 1 : mismatch
	blo	.asopc	* ACC B < 1 : 4-char match
	stx	xsave	* save X
	ldx	mneptr	* ACC B = 1 : 3-char match if mne[3] = space
	ldaa	,x	* read mne[3]
	bsr	mneinc	* advance mneptr
	ldx	xsave	* restore X
	cmpa	#' '
	beq	.asopc	* 3-char match
	bra	.asnxm	* else mismatch
*--------------------------------------------------------------------
.ascom	tstb		* else, check remaining characters (ACC B)
* (mnemonic too long error should not occur if N command works correctly)
	beq	.aser3	* if none, error: mnemonic too long
* mnemonic not matched, check next mnemonic
.asnxm	tstb		* any mnemonic characters left to consume?
	beq	.asckm	* if none, proceed with mneptr check
	bsr	mneinc	* increment mneptr and decrement ACC B
	bne	.asnxm	* consume remaining mnemonic characters
.asckm	ldx	mneptr	* end of mnemonic table reached?
	ldx	,x
	cpx	mneend
	bne	.asmne	* check next mnemonic
.aser4	ldaa	#4	* error: unrecognized mnemonic
	bra	.nserx
*--------------------------------------------------------------------
.aser3	ldaa	#3	* error: mnemonic too long
.nserx	jmp	aserx
*--------------------------------------------------------------------
* mnemonic matched - ACC A & B are available at this point, X points to field terminator
.asopc	jsr	mneidx	* return mnemonic index (1-based)
	staa	curins	* save current mnemonic
	oraa	#$80	* set bit 7 to indicate token
	ldx	linptr	* roll back to start of mnemonic field
	staa	,x	* store mnemonic token
	inx
.tmemt	pula		* restore argument/result
	staa	,x	* store field terminator
	inx		* advance line pointer (X)
.tmend	rts		* return (terminator in ACC A)

**********************************************************************
* uprc - Convert character in ACC A to uppercase and return it
**********************************************************************
uprc
	cmpa	#'a'
	blo	.uprc
	cmpa	#'z'
	bhi	.uprc
	anda	#$DF
.uprc	rts

**********************************************************************
* mneinc - increment mneptr and decrement character count in ACC B
**********************************************************************
mneinc
	inc	mneptr+1	* increment mneptr
	bne	.mnend	* check for rollover
	inc	mneptr	* increment upper byte if needed
.mnend	decb		* count consumed character
	rts

**********************************************************************
* gets - Read line of text into buffer addressed by X (not preserved).
*  Returns number of characers read in ACC B, with flags set accordingly.
**********************************************************************
gets
	clrb		* clear character count
.getch	bsr	getch	* read character
	cmpa	#BSIN	* check for BS
	beq	.gsbs	* if BS, proceed below
	cmpa	#CR	* else, check for CR
	beq	.gets	* if CR, done
	staa	,x	* else, store char and advance pointer
	inx
	jsr	ECHO	* echo character
	incb		* count++
	bra	.getch	* loop
*--------------------------------------------------------------------
.gsbs	tstb		* check character count
	beq	.getch	* if zero, drop BS, read next char
	jsr	ECHO	* else, echo BS
	dex		* drop last character read
	decb		* count--
	bra	.getch	* loop
*--------------------------------------------------------------------
.gets	jsr	ECHO	* echo CR
	ldaa	#NUL
	staa	,x
	tstb		* set flags for character count
	rts

**********************************************************************
* getc - Read character from console (w/echo) and return it in ACC A.
**********************************************************************
getc
	bsr	getch
	jmp	ECHO	* call ECHO and return

**********************************************************************
* getch - Read character from console (no echo) and return it in ACC A.
**********************************************************************
getch
	ldaa	KBD_CR
	bpl	getch
	ldaa	KBDDAT
	anda	#$7F
	rts

**********************************************************************
* newfwd - add forward reference (name on dstack, length in ACC B).
*	 - returns allocated symbol table entry address in X
*	 - returns Z=1 on overflow, Z=0 on success
**********************************************************************
newfwd
* check for forward reference table overflow
	ldx	fwdref	* point to next symbol table entry
	cpx	#FWDEND	* test against end of table
	beq	.nfend	* return Z=1 if overflow
* set symbol name and address
	bsr	setsym
* advance fwdref ponter to next symbol table entry:
	ldaa	fwdref
	ldab	fwdref+1
	addb	#STESIZ
	adca	#0	* propagate carry
	staa	fwdref
	stab	fwdref+1
	ldaa	#1	* set Z=0 for success
.nfend	rts

**********************************************************************
* cmplbl - compare label (on dstack, length in ACC B) with symbol at X
*	 - returns Z=1 if equal, Z=0 if not equal, preserves ACC B.
**********************************************************************
cmplbl
	pshb		* save B
	sts	ssave	* save S
	stx	xsave	* save current symbol pointer
	tba		* copy label length into ACC A
	bsr	incx	* move X to end of name (sym + ACC B)
	cmpb	#NAMLEN	* symbol is full-length?
	beq	.clful	* if yes, skip
	ldaa	,x	* else, must check for NUL at end
	bne	.clend	* if not NUL, exit with Z=0
.clful	lds	datasp	* load data stack pointer
* compare label with symbol name field (compare backwards):
.clcmp	pula		* next label character from data stack
	dex
	tst	,x	* symbol table character is negative?
	bpl	.clgtz	* if no, skip
	nega		* negate ACC A accordingly
.clgtz	cmpa	,x	* sym[b-1] = char?
	bne	.clend	* if not equal, return Z=0
	decb		* else, b--
	bne	.clcmp	* loop until done, then exit with Z=1
.clend	tpa		* save status flags
	ldx	xsave	* restore X
	lds	ssave	* restore S
	pulb		* restore B
	tap
	rts

**********************************************************************
* getlcl - lookup local symbol (name on dstack, length in ACC B).
*	 - returns Z=1 if not found, Z=0, value in AB on success
**********************************************************************
getlcl
	ldx	#SYMTAB-STESIZ	* X = symbol table start - STESIZ
.glnxt	ldaa	#STESIZ	* advance X to next entry
	bsr	incx
	cpx	lclsym	* test against current end of table
	beq	.glend	* return Z=1 if hit end without match
	bsr	cmplbl	* compare label with symbol name
	bne	.glnxt
	ldaa	SYMADR,X	* load MSB of value
	ldab	SYMADR+1,X	* load LSB of value
	ldx	#1	* return X=1, Z=0 to indicate success
.glend	rts

**********************************************************************
* getgbl - lookup local symbol (name on dstack, length in ACC B).
*	 - returns Z=1 if not found, Z=0, value in AB on success
**********************************************************************
getgbl
	ldx	gblsym	* X = symbol table start - STESIZ
.ggnxt	ldaa	#STESIZ	* advance X to next entry
	bsr	incx
	cpx	#SYMTAB	* test against end of table
	beq	.ggend	* return Z=1 if hit end without match
	bsr	cmplbl	* compare label with symbol name
	bne	.ggnxt
	ldaa	SYMADR,X	* load MSB of value
	ldab	SYMADR+1,X	* load LSB of value
	ldx	#1	* return X=1, Z=0 to indicate success
.ggend	rts

**********************************************************************
* incx - increment X by the value in ACC A (precondition: ACC A ≥ 1)
**********************************************************************
incx
	inx		* X++
	deca		* A--
	bne	incx	* while ( A != 0 )
	rts

**********************************************************************
* setsym - set name (on dstack, length in ACC B), value of symbol at X
**********************************************************************
setsym
* store program counter to symbol address field:
	ldaa	prgctr+1	* init low byte of address
	adda	symoff	* add symbol offset
	staa	SYMADR+1,X
	ldaa	prgctr	* init high byte of address
	adca	#0	* propagate carry
	staa	SYMADR,X
	ldaa	#SYMADR	* ACC A = offset to symbol field
	bsr	incx	* move X past name field (sym + SYMADR)
	ldaa	#SYMADR	* re-init A
.syzro	cba		* ACC A = ACC B?
	beq	.sycpy
	dex
	clr	,x	* clear unused byte of name field
	deca
	bne	.syzro
	rts		* zero length label passed?
* copy label into symbol name field (copy backwards):
.sycpy	bsr	dpula	* pop label character from data stack
	dex
	staa	,x	* sym[b-1] = char
	decb		* b--
	bne	.sycpy
	rts

**********************************************************************
* newlcl - add local symbol (name on dstack, length in ACC B).
*	 - returns allocated symbol table entry address in X
*	 - returns Z=1 on overflow, Z=0 on success
**********************************************************************
newlcl
* check for local symbol table overflow
	ldx	lclsym	* point to next symbol table entry
	cpx	#FWDREF	* test against end of symbol table
	beq	.nlend	* return Z=1 if overflow
* set symbol name and address
	bsr	setsym
* advance lclsym ponter to next symbol table entry:
	ldaa	lclsym
	ldab	lclsym+1
	addb	#STESIZ
	adca	#0	* propagate carry
	staa	lclsym
	stab	lclsym+1
	ldaa	#1	* set Z=0 for success
.nlend	rts

**********************************************************************
* newgbl - add global symbol (on dstack, length in ACC B).
*	 - returns allocated symbol table entry address in X
*	 - returns Z=1 on overflow, Z=0 on success
**********************************************************************
newgbl
* check for global symbol table overflow
	ldx	gblsym	* point to next symbol table entry
	cpx	#GBLBOT-STESIZ	* test against end of symbol table
	beq	.ngend	* return Z=1 if overflow
* set symbol name and address
	bsr	setsym
* advance gblsym ponter to next symbol table entry (grows down):
	ldaa	gblsym+1
	suba	#STESIZ
	staa	gblsym+1
	ldaa	gblsym
	sbca	#0
	staa	gblsym
	ldaa	#1	* set Z=0 for success
.ngend	rts

**********************************************************************
* dpsha - push ACC A onto data stack
**********************************************************************
dpsha
	sts	ssave	* save S
	lds	datasp	* load data stack pointer
	psha		* push ACC A onto data stack
	sts	datasp	* save data stack pointer
	lds	ssave	* restore S
	rts

**********************************************************************
* dpula - pull ACC A from data stack
**********************************************************************
dpula
	sts	ssave	* save S
	lds	datasp	* load data stack pointer
	pula		* pull ACC A from data stack
	sts	datasp	* save data stack pointer
	lds	ssave	* restore S
	rts

**********************************************************************
* asrc - A (assemble source) command
*
* Plan:
*  - read optional label + FS
*  - read required mnemonic + FS
*  - if opcode requires argument, read argument + FS
*  - read to end of line
*  - repeat
**********************************************************************
asrc
	ldaa	#1
	staa	fwdrok	* allow forward references
	ldx	#SYMTAB
	stx	lclsym	* init local symbol table
	ldx	#SYMTAB-STESIZ
	stx	gblsym	* init global symbol table
	ldx	#FWDREF	* init forward reference table
	stx	fwdref
	ldx	#DFLTPC	* initialize program counter
	stx	prgctr
	stx	modptr	* and module pointer
	ldx	#-1	* init line number to -1
	stx	line
	ldx	#srcbuf	* let X track current source position
* assemle next line
.asnxl	stx	linptr	* save start of current line
	ldx	line	* 16-bit increment of line number
	inx
	stx	line
	ldx	linptr	* restore X
	clrb		* track label length in ACC B
	ldaa	,x	* read first character of line
	bne	.aneos	* if NUL, end of source, else see below
* end of source - resolve any forward references
.anxfr	ldx	fwdref	* load current end of fwdref table
	cpx	#FWDREF	* at start of table?
	beq	.asrc	* if yes, return
	ldab	#STESIZ	* X -= STESIZ
.nxtste	dex
	decb
	bne	.nxtste	* loop until next entry reached
	stx	fwdref	* save current position in table
	ldab	datasp+1	* save datasp on stack
	pshb
	ldab	datasp
	pshb
	ldaa	,x	* load first character of reference
	bpl	.ntpcr	* check for negated character (PCR symbol)
	nega		* recover original character
.ntpcr	psha		* save character on stack
	jsr	pshsym	* push symbol on data stack, ACC B=len
	pula		* reload first character
	cmpa	#'.'	* check for local symbol
	bne	.gblrf	* if not local, check for global
	jsr	getlcl	* search for local
	bra	.anyrf	* proceed below
*--------------------------------------------------------------------
.gblrf	jsr	getgbl	* search for global
.anyrf	pshb		* save return value (AB) on stack
	psha
	tpa		* save status in ACC A
	pulb		* transfer return value (AB) to absave
	stab	absave
	pulb
	stab	absave+1
	pulb		* restore saved datasp from stack (pop symbol)
	stab	datasp
	pulb
	stab	datasp+1
	tap		* restore status from ACC A
	beq	.aser7	* error: unresolved reference
	ldaa	absave	* restore AB from absove
	ldab	absave+1
	ldx	fwdref	* reload symbol table entry pointer
	tst	REFPCR,x	* check for PC-relative fwdref
	bpl	.2bref	* (absolute case (2bref) handled below)
	ldx	SYMADR,x	* X = PC of branch displacement to patch
	inx		* X = PC of next instruction
	jsr	cvtrel	* convert AB to X-relative address
	dex		* X = PC of branch displacement to patch
	stab	,x	* patch branch displacement
	bra	.anxfr	* proceed to next table entry
*--------------------------------------------------------------------
.2bref	ldx	SYMADR,x	* load address to patch
	staa	0,x	* patch MSB
	stab	1,x	* patch LSB
	bra	.anxfr	* proceed to next table entry
*--------------------------------------------------------------------
.aser7	ldaa	#7	* error: unresolved reference
	bra	.aserx
*--------------------------------------------------------------------
.asrc	jsr	newline
clsmod	ldx	prgctr	* subroutine: close current module
	cpx	modptr
	beq	.cmend	* if module empty, return; else
	ldx	#modptr
	bsr	prtadr	* print module start
	ldaa	#'-'
	jsr	ECHO
	ldx	#prgctr
	bsr	prtadr	* print module end
	jsr	newline
.cmend	rts		* return
*--------------------------------------------------------------------
.aneos	cmpa	#EMPTY	* blank line?
	beq	.toeol	* if blank, skip to end of line
	jsr	iscom	* check for comment
	bne	.ancom	* if not comment, continue below
.toeol	jmp	.aseol	* else, skip to end of line
*--------------------------------------------------------------------
prtadr	ldaa	0,x	* subroutine: print address at X
	jsr	PRBYTE
	ldaa	1,x
	jmp	PRBYTE	* call PRBYTE and return
*--------------------------------------------------------------------
.ancom
	clr	symoff	* zero symbol offset
* test for local symbol
	clr	lclflg	* clear local symbol flag
	cmpa	#'.'	* check for local label
	bne	.aslbl	* if global, skip next line
	inc	lclflg	* set local symbol flag
* read label and push onto stack
.aslbl	staa	absave	* save current character
	cmpa	#':'	* check for optional colon at end of label
	bne	.aslfs	* if not colon, check for FS
	inx		* else, skip colon
	ldaa	,x	* read next source character
	beq	.aslel	* if EOL, skip to line end handling below
.aslfs	cmpa	#FS	* check for end of field
	beq	.aslbe	* end of field, check label
	cmpa	absave	* check for non-FS character after colon
	bne	.aser0	* error: invalid symbol
	jsr	issymc	* valid symbol character?
	bne	.aser0	* error: invalid symbol
	jsr	dpsha	* push character on data stack
	incb		* and count it
	inx		* advance to next source character
	ldaa	,x	* read it
	bne	.aslbl	* loop, if not NUL [end of line (EOL)]
.aslel	dex		* EOL, back up to cancel out next inx
* reached end of field/line, with (ACC B ≠ 0) or without (ACC B = 0) label
.aslbe	inx		* advance to next source character
	stx	linptr	* save pointer to mnemonic or EOL
	stab	lbllen	* store length of label and set flags
	beq	.asmnf	* no label, proceed to mnemonic
	tst	lclflg	* test local flag
	beq	.asgbl
	jsr	newlcl	* add local symbol
	bra	.asckv
*--------------------------------------------------------------------
.aser0	clra		* error: invald symbol
.aserx	jmp	aserx
*--------------------------------------------------------------------
.aser1	ldaa	#1	* error: expected expression
	bra	.aserx
*--------------------------------------------------------------------
.aser2	jsr	dpula	* symbol table full, pop symbol
	decb
	bne	.aser2
	ldaa	#2
	bra	.aserx
*--------------------------------------------------------------------
.asgbl	jsr	newgbl	* add global symbol
.asckv	beq	.aser2	* error: symbol table full
	stx	symptr	* save pointer to symbol
* handle mnemonic field
.asmnf
	ldx	linptr	* restore current source pointer
	ldaa	,x	* read first character of mnemonic field
	bne	.asmnn	* skip if not NUL (end-of-line)
	inx		* consume NUL character
	jmp	.asnxl	* go to next line (out of branch range)
.asmnn	jsr	iseof	* check for empty operand field
	beq	.toeol	* if empty, ignore rest of line
	jsr	iscom	* check for comment
	beq	.toeol	* if comment, ignore rest of line
	anda	#$7F	* strip high bit (token flag)
	staa	curins	* save current instruction
	inx		* consume mnemonic token
	clr	curmod	* default addressing mode to acc/inh
	tst	,x	* test field separator (FS/NUL) character
	beq	.ckarg	* if NUL (end-of-line), skip to .noarg (branch too far)
	inx		* else, consume field terminator (FS)
* handle fcb pseudo-op
	cmpa	#FCB	* check for FCB pseudo-op
	bne	.ntfcb	* if not FCB, continue below
	jsr	stbyte	* store byte(s)
	bra	.goeol	* skip to end of line
*--------------------------------------------------------------------
.ntfcb
* handle fcc pseudo-op
	cmpa	#FCC	* check for FCC pseudo-op
	bne	.ntfcc	* if not FCC, continue below
	jsr	ststrg	* store string constant
	bra	.goeol	* skip to end of line
*--------------------------------------------------------------------
.ntfcc
* handle fdb pseudo-op
	cmpa	#FDB	* check for FDB pseudo-op
	bne	.ntfdb	* if not FDB, continue below
	jsr	stword	* store word(s)
	bra	.goeol	* skip to end of line
*--------------------------------------------------------------------
.ntfdb
	inc	symoff	* set symbol offset = 1
* read optional argument and save it
	ldaa	,x	* read next source char
	jsr	iseof	* test for FS/EOL
.ckarg	beq	.noarg	* if no argument, continue below
	clr	curopd	* initialize operand=0 (e.g. for ",X")
	clr	curopd+1
	cmpa	#'#'	* else, check for immediate operand
	bne	.ntimm
	ldaa	#imm16	* default to imm16 mode
	staa	curmod
	inx		* consume source character
	jsr	rdexpr	* returns expr in AB, or Z=1 if none
	beq	.aser1	* error: expected expression
	jsr	prntab	* print operand (preserves AB)
	stab	curopd+1	* save LSB
	staa	curopd	* save MSB
	bne	.noarg	* skip if MSB≠0
	ldaa	#imm	* 8-bit operand: use imm mode
	staa	curmod
.imm16	bra	.noarg	* done with immediate operand
*--------------------------------------------------------------------
.ntimm
	jsr	rdexpr	* returns expr in AB, or Z=1 if none
	beq	.ckidx	* if no operand, check for indexd mode
	staa	curopd	* else, save operand
	stab	curopd+1
	jsr	prntab	* print operand (preserves AB)
* ACC B is available at this point
	ldab	#dir	* default to direct mode
	stab	curmod
	tsta		* check for zero MSB
	beq	.isdir
	ldab	#ext	* 16-bit operand: extended mode
	stab	curmod
.isdir
	ldaa	curins	* reload current insruction
	cmpa	#ORG	* check for ORG pseudo-op
	bne	.ntorg
	stx	linptr	* save source position
	jsr	clsmod	* close current module
	ldx	curopd	* ORG: copy operand to PC
	stx	prgctr
	stx	modptr
	ldx	linptr	* restore source position
.goeol	bra	.aseol	* skip to end of line
*--------------------------------------------------------------------
.ntorg
	cmpa	#EQU	* check for EQU pseudo-op
	bne	.ntequ
	stx	xsave
	ldx	symptr
	ldaa	curopd
	staa	SYMADR,x
	ldaa	curopd+1
	staa	SYMADR+1,x
	ldx	xsave
	bra	.goeol	* skip to end of line
*--------------------------------------------------------------------
.ntequ

.ckidx
* check for [ [<expr>] ',' ] 'X' : indexed mode
	ldaa	,x	* read next source char
	cmpa	#','
	bne	.asntx	* if no match, not ,X
	inx		* else, consume comma
	ldaa	,x	* read next source char
	jsr	lowc	* convert to lowercase
	cmpa	#'x'	* test for ,X
	bne	.asntx	* if no match, not ,X
	ldab	#idx	* else, idx mode
	stab	curmod
.asntx

* lookup opcode/mode
.noarg
	ldaa	curins	* ACC A: insruction
	ldab	curmod	* ACC B: addressing mode
	jsr	prntab	* print mnemonic/mode (preserves AB)
	jsr	mneopc	* returns opcode/mode in A/B
	tsta		* check opcode
	beq	.aser5	* if zero, error: invalid instruction
	staa	curopc	* save opcode
	stab	curmod	* save (possibly updated) mode
	jsr	prntab	* print opcode/mode (preserves AB)

* opcode/mode still in A/B
	bsr	stcode	* assemble opcode
	tstb		* accinh = 0 (no operand)
	beq	.aseol	* if no operand, skip to end of line
	cmpb	#rel	* rel (PC-relative displacement)
	bne	.ntrel	* if not PC-relative, skip
	ldaa	curopd	* load absolute address
	ldab	curopd+1
	cmpa	#INVADR/$100	* check for fwdref placeholder
	bne	.notfw
	cmpb	#INVADR%$100
	bne	.notfw	* if not fwdref, skip
	bsr	pcrref	* mark fwdref as PC-relative
	clra		* use zero displacement for fwdref
	bra	.stdsp	* and continue below
*--------------------------------------------------------------------
.notfw	stx	linptr	* save source position
	ldx	prgctr	* X = PC of next instruction
	inx		* (prgctr points at branch operand)
	bsr	cvtrel	* convert AB to PC-relative address
	bpl	.fwdbr
	inca		* MSB should be $FF for reverse branch
.fwdbr	tpa		* save test status of MSB in ACC A
	ldx	linptr	* restore source position
	tap		* restore status of MSB from ACC A
	bne	.aser6	* MSB must be zero, else out of range
	tba		* move displacement to ACC A
.stdsp	bsr	stcode	* store displacement
	bra	.aseol	* skip to EOL
*--------------------------------------------------------------------
.ntrel	cmpb	#ext	* dir (16-bit operand)
	beq	.asmsb
	cmpb	#imm16	* imm16 (16-bit operand)
	bne	.aslsb
.asmsb	ldaa	curopd	* store MSB
	bsr	stcode
.aslsb
	ldaa	curopd+1	* store LSB
	bsr	stcode
.aseol	ldaa	,x	* read next source char
	inx
	tsta		* check for nul
	bne	.aseol	* skip until end of line
	stx	linptr	* update line pointer
	jmp	.asnxl	* proceed to next line
*--------------------------------------------------------------------
.aser5	ldaa	#5	* error: invalid instruction
	bra	.goerx
*--------------------------------------------------------------------
.aser6	ldaa	#6	* error: branch out of range
.goerx	jmp	.aserx
*--------------------------------------------------------------------

**********************************************************************
* pcrref - mark forward reference at symptr as PC-relative
**********************************************************************
pcrref
	stx	xsave	* save X
	ldx	symptr	* X = symptr
	neg	REFPCR,x	* mark symbol as PC-relative offset
	ldx	xsave	* restore X
	rts

**********************************************************************
* cvtrel - convert address in AB to X-relative address
*	returns status of MSB in P
**********************************************************************
cvtrel
	stx	absave	* store base address in absave
	subb	absave+1	* B = B - LSB of base
	sbca	absave	* A = A - MSB of base (with borrow)
	rts

**********************************************************************
* aliasb - resolve branch aliases for mnemonic in ACC A
**********************************************************************
aliasb
	cmpa	#BHS	* BHS => BCC
	bne	.ntbhs
	ldaa	#BCC
	rts
.ntbhs	cmpa	#BLO	* BLO => BCS
	bne	.ntblo
	ldaa	#BCS
.ntblo	rts

**********************************************************************
* stcode - store byte (in ACC A) at current PC and increment PC
**********************************************************************
stcode
	stx	xsave	* save X
	ldx	prgctr	* X = prgctr
	staa	,x	* store code byte
	inc	prgctr+1	* increment LSB
	bne	.stcod	* rollover?
	inc	prgctr	* increment MSB
.stcod	ldx	xsave	* restore X
	rts

**********************************************************************
* mneidx - return current mnemonic index (1-based) in A
**********************************************************************
mneidx
	ldaa	mneptr	* read high byte
	ldab	mneptr+1	* read low byte
	subb	#mnemon%$100	* mneptr - mnemon (low byte)
	sbca	#mnemon/$100	* mneptr - mnemon (high byte)
* divide by 4 [mnemonic size] (shift right two bits)
	bsr	div4ab
	tba
	rts

**********************************************************************
* mneopc - lookup opcode for mnemonic (ACC A) and address mode (ACC B)
**********************************************************************
mneopc
	bsr	aliasb	* resolve branch aliases
	psha
	ldaa	#2	* init pass = 3
	staa	mneitr
	pula
	stx	xsave	* save X
.again	dec	mneitr
	bmi	.mneop	* exit after 2nd pass
	ldx	#opcode-2	* init X to track opcode table entry
.mnene	inx		* advance to mode field
.opnxt	inx		* advance to next entry
	cpx	#opcend	* check for end of opcode table
	beq	.again	* at end of table, try again
	cmpa	,x	* check opcode
	bne	.mnene
	inx
	cmpb	,x	* check mode
	beq	.mneop	* if matched exactly, return
	tst	mneitr	* on 2nd pass, allow fuzzy match
	bne	.opnxt
* special case: input mode of `imm` may match `imm16`
* special case: input mode of `ext` may match `rel`
* special case: input mode of `dir` may match `rel` or `ext`
*  Note that in the latter case, this relies on the fact that all
*  `dir` opcodes precede the `ext` equivalents in the opcode table.
	bitb	,x	* AND mask in ACC B with mode in mem
	beq	.opnxt	* if mask matching failed, loop
	ldab	,x	* else, load opcode mode into ACC B
.mneop	stx	opcptr
	ldx	xsave	* restore X
	pshb		* save B
	ldaa	opcptr	* compute index:
	ldab	opcptr+1
	subb	#opcode%$100	* subtract opcodes from opcptr
	sbca	#opcode/$100
	bsr	div2ab	* divide by 2 (table entry size)
	tba
	pulb		* restore B
	rts

**********************************************************************
* stbyte - read list of bytes from X address and store them at prgctr
**********************************************************************
stbyte
.stbne	jsr	rdexpr	* returns expr in AB, or Z=1 if none
	beq	.stbyt	* if no expression, return
	tba		* else, move LSB to ACC A
	bsr	stcode	* store byte at PC and increment
	ldaa	,x	* read next source character
	cmpa	#','	* check for comma
	bne	.stbyt	* if not comma, return
	inx		* consume comma
	bra	.stbne	* proceed to next expression
.stbyt	rts

**********************************************************************
* stword - read list of words from X address and store them at prgctr
**********************************************************************
stword
.stwne	bsr	rdexpr	* returns expr in AB, or Z=1 if none
	beq	.stwrd	* if no expression, return
	jsr	prntab
	bsr	stcode	* store MSB at PC and increment
	tba		* else, move LSB to ACC A
	bsr	stcode	* store LSB at PC and increment
	ldaa	,x	* read next source character
	cmpa	#','	* check for comma
	bne	.stwrd	* if not comma, return
	inx		* consume comma
	bra	.stwne	* proceed to next expression
.stwrd	rts

**********************************************************************
* div4ab,div2ab - divide AB by 4,2
**********************************************************************
div4ab
	lsra		* shift right upper
	rorb		* shift right lower
div2ab
	lsra		* shift right upper
	rorb		* shift right lower
	rts

**********************************************************************
* ststrg - read quoted string addressed by X and store it at prgctr
* 	 - NOTE: clobbers ACC B
**********************************************************************
ststrg
	ldaa	,x	* read next source char, used as quote
	inx		* consume source character
	bsr	iseof	* check for FS/EOL
	beq	.ststr	* if end of field/line, return
	tab		* save quote character in ACC B
.stsnc	ldaa	,x	* read next source character
	inx		* consume source character
	bsr	iseof	* check for FS/EOL
	beq	.ststr	* if end of field/line, return
	cba		* else, compare to quote character
	beq	.ststr	* if equal, return
	jsr	stcode	* store character at PC and increment
	bra	.stsnc	* proceed to next character
.ststr	rts

**********************************************************************
* issymc - check whether the character in ACC A is allowed in symbol,
*	given character position in ACC B (0 = first character), which
*	is preserved.
*	Allowed characters are upper/lower case letters, underscore,
*	period (1st char only), and numbers (except first char).
**********************************************************************
issymc
	pshb		* save B
	tstb		* check character position
	beq	.is1st	* if first char, skip--ACC B already 0
	clrb		* else, default ret status to true (0)
	cmpa	#'0'
	blo	.ntsym	* is invalid symbol character?
	cmpa	#'9'
	bls	.issym	* ASCII digit?
	bra	.is2nd	* else, skip below
*--------------------------------------------------------------------
.is1st	cmpa	#'.'
	beq	.issym	* period?
.is2nd	cmpa	#_
	beq	.issym	* underscore?
	cmpa	#'A'
	blo	.ntsym	* invalid symbol character?
	cmpa	#'z'
	bhi	.ntsym	* invalid symbol character?
	cmpa	#'Z'
	bls	.issym	* ASCII upper case letter?
	cmpa	#'a'
	bhs	.issym	* ASCII lower case letter?
.ntsym	ldab	#1
.issym	tstb		* condition flags - Z=1 means true
	pulb		* restore B
	rts

**********************************************************************
* pshsym - read symbol at X address (push on dstack, length in ACC B)
**********************************************************************
pshsym
	clrb		* clear length
.psnxt	ldaa	,x	* read next character
	bpl	.psgtz	* if non-negative, skip
	nega		* else, negate character
.psgtz	bsr	iseof	* check for FS/EOL
	beq	.psend	* if end, return
	bsr	issymc	* valid symbol character?
	bne	.psend	* if not, return
.pssym	incb		* count it
	jsr	dpsha	* push it
	inx		* advance to next char
	cmpb	#NAMLEN	* read maximum name length?
	blo	.psnxt	* if no, loop, else return
.psend	rts

**********************************************************************
* iseof - Compare source character in ACC A with end of field/line
**********************************************************************
iseof
	tsta		* test for NUL
	beq	.iseof
	cmpa	#FS	* test for FS
.iseof	rts

**********************************************************************
* rdexpr - read expression starting from X address, return value in AB
* 	 - returns with Z=0 if expression found, Z=1 if not found
**********************************************************************
rdexpr
	bsr	rdvalu	* read a value
	beq	.reend	* return error if no value found
	pshb		* save return value
	psha

.renxt	ldaa	,x	* read next source character
	bsr	iseof	* is FS/NUL?
	beq	.rerok	* if so, return success status

	stx	linptr	* save X
	ldx	#binops	* X = pointer to binops table
.reopl	ldab	,x	* ACC B = operator from table
	bne	.reopx	* if not NUL, skip
	ldx	linptr	* else, restore X
	bra	.rerok	* and return success status
*--------------------------------------------------------------------
.reopx	inx		* advance to operation address field
	cba		* operator match?
	beq	.reopm	* if matched, skip
	inx		* else, advance to next table entry
	inx
	bra	.reopl	* and loop
*--------------------------------------------------------------------
.reopm	ldx	,x	* load operation address
	jsr	xpshx	* and push it on X stack
	ldx	linptr	* restore X
	inx		* consume operator character
	bsr	rdvalu	* read next value
	beq	.rerok	* return original value if none found
	stx	linptr	* save X
	jsr	xpulx	* reload operation address
	staa	absave	* save returned value
	stab	absave+1
	pula		* reload previous expr value
	pulb
	jsr	,x	* perform operation
	ldx	linptr	* restore X
	pshb		* push result on stack
	psha
	bra	.renxt	* and loop
.rerok	ldaa	#1	* set exit status (success)
.rexit	pula		* restore return value
	pulb
.reend	rts

**********************************************************************
* rdvalu - read value starting from X address, return value in AB
* 	 - returns with Z=0 if expression found, Z=1 if not found
**********************************************************************
rdvalu
	stx	linptr	* lineptr = first digit/char/symbol
	clra		* set initial value to 0
	clrb
	jsr	dpshab	* push it onto data stack
	clr	negflg	* clear negative flag
	ldaa	,x	* read source char into ACC A
	cmpa	#'-'	* check for minus sign
	bne	.ntneg	* if not minus, continue below
	inc	negflg	* else, set negative flag
	inx		* consume '-'
	ldaa	,x	* read source char into ACC A
	stx	linptr	* lineptr = first digit/char/symbol
.ntneg
	cmpa	#'''	* check for character
	bne	.ntchr
	stx	linptr	* lineptr = first digit/char/symbol
	inx		* consume quote
	ldaa	,x	* read source char into ACC A
	bsr	iseof	* check for FS/EOL
	beq	.toret	* return 0
	inx		* consume character
	ldab	,x	* read next char into ACC B
	cmpb	#'''	* has optional quote?
	bne	.ntqot	* if no, skip below
	inx		* else, consume quote
.ntqot	psha		* save char on stack
	jsr	dpulab	* pull 0 from data stack
	pulb		* replace LSB with char
	jsr	dpshab	* push char value on stack
.toret	bra	.rxret	* return
*--------------------------------------------------------------------
* ACC A contains source char, ACC B available at this point
.ntchr
* save datasp on stack
	ldab	datasp+1
	pshb
	ldab	datasp
	pshb

* local symbol?
	cmpa	#'.'	* check for local symbol
	bne	.ntlcl	* if not local, check for global
	ldaa	1,x	* read next character into ACC A
	jsr	iseof	* check for FS/EOL
	beq	.pgctr	* special case for '.', see below
	jsr	pshsym	* push sym on dstack, length in ACC B
	jsr	xpshx	* save current source position
	jsr	getlcl	* search for local
	bra	.cksym
*--------------------------------------------------------------------
.pgctr
	inx		* consume '.'
	ldaa	prgctr	* load program counter in AB
	ldab	prgctr+1
	pshb		* save ACC B
	ldab	#1	* set flags - Z=0
	pulb		* restore ACC B
	bra	.cksym	* continue below
*--------------------------------------------------------------------
.ntlcl
* global symbol?
	clrb		* indicate first character of symbol
	jsr	issymc	* check for global symbol
	bne	.nosym	* if not symbol, proceed below
	jsr	pshsym	* push sym on dstack, length in ACC B
	jsr	xpshx	* save current source position
	jsr	getgbl	* search for global
.cksym
* Note: Z=1 if symbol not found, AB contains symbol value when Z=0
	bne	.symok	* test return status (Z flag)
	tst	fwdrok	* fwdref allowed?
	bne	.mkfwr	* if fwdref allowed, skip
	jsr	xpulx
	stx	linptr	* advance linptr to indicate failure
	jsr	xpshx
	bra	.rffff	* return placeholder address
*--------------------------------------------------------------------
.mkfwr	jsr	newfwd	* no symbol, create forward reference
	stx	symptr	* save pointer to symbol
.rffff	ldaa	#INVADR/$100	* return placeholder address
	ldab	#INVADR%$100
.symok	pshb		* save symbol value (AB) on stack
	psha

	jsr	xpulx	* restore current source position (X)

	pulb		* transfer symbol value to absave
	stab	absave
	pulb
	stab	absave+1

* pop symbol name pushed on dstack by pshsym above
	pulb		* restore saved datasp from stack
	stab	datasp
	pulb
	stab	datasp+1

	ldab	absave+1	* transfer symbol value back to stack
	pshb
	ldab	absave
	pshb

	jsr	dpulab	* discard 0 on dstack (clobbers AB & absave)

	pula		* reload symbol value
	pulb		* reload LSB of return value
	jsr	dpshab	* push symbol value on dstack
.rxret	bra	.rxpnd	* return value on dstack
*--------------------------------------------------------------------
* ACC A contains source char, ACC B available at this point
.nosym
	pulb		* pull (discard) saved datasp from stack
	pulb
* read a number
.rdnum
	ldab	#10	* default to decimal
	stab	valbas
	cmpa	#'$'	* check for hex value
	bne	.dodig
	ldaa	#16	* switch to hexadecimal
	staa	valbas
	inx		* temporarily advance to next char
	stx	linptr	* lineptr = first digit/char/symbol
	dex		* compensate for next inx
.rdxch	inx		* consume character
	ldaa	,x	* read next source char
.dodig	cmpa	#'0'
	blo	.rxpnd	* return - not a number
	cmpa	#'9'
	bhi	.ntdec	* not decimal, maybe hex?
	suba	#'0'	* get difference from '0'
	bra	.digit
.ntdec	jsr	lowc	* convert to lowercase
	cmpa	#'a'
	blo	.rxpnd	* return - not a number
	cmpa	#'f'
	bhi	.rxpnd	* return - not a number
	suba	#'a'	* get difference from 'a'
	adda	#10	* add ten
.digit	psha		* save digit on stack
	ldaa	valbas
	cmpa	#10	* base is decimal?
	bne	.dohex	* if not, see below
	bsr	dpulab	* pull value from data stack
	bsr	val10x	* multiply by 10
	bra	.addig	* continue below
.dohex	bsr	dpulab	* pull value from data stack
	bsr	val16x	* multiply by 16
.addig	stab	absave+1	* save LSB
	pulb		* pop digit from stack
	addb	absave+1	* add it to LSB of value
	adca	#0	* propagate carry
	bsr	dpshab	* save result onto data stack
	bra	.rdxch	* move to next character
*--------------------------------------------------------------------
.rxpnd	bsr	dpulab	* pull result from stack
	tst	negflg	* check negative flag
	beq	.rxsts	* if negflg=0, return
	bsr	negab	* else, negate result
.rxsts	cpx	linptr	* set exit status
	rts		* return

**********************************************************************
* xpshx - push X onto data stack
**********************************************************************
xpshx
	pshb		* save B
	psha		* save A
	stx	xsave	* save X
	sts	ssave	* save S
	lds	xstksp	* load X stack pointer
	ldaa	xsave	* ACC A = MSB of X
	ldab	xsave+1	* ACC B = LSB of X
	pshb		* push LSB onto data stack
	psha		* push MSB onto data stack
	sts	xstksp	* save X stack pointer
	lds	ssave	* restore S
	pula		* restore A
	pulb		* restore B
	rts

**********************************************************************
* xpulx - pull X from data stack
**********************************************************************
xpulx
	pshb		* save B
	psha		* save A
	sts	ssave	* save S
	lds	xstksp	* load X stack pointer
	pula		* pull X MSB from data stack
	pulb		* pull X LSB from data stack
	staa	xsave	* save X MSB in memory
	stab	xsave+1	* save X LSB in memory
	sts	xstksp	* save X stack pointer
	lds	ssave	* restore S
	pula		* restore A
	pulb		* restore B
	ldx	xsave	* reload X from memory
	rts

**********************************************************************
* dpshab - push AB onto data stack
**********************************************************************
dpshab
	sts	ssave	* save S
	lds	datasp	* load data stack pointer
	pshb		* push ACC B onto data stack
	psha		* push ACC A onto data stack
	sts	datasp	* save data stack pointer
	lds	ssave	* restore S
	rts

**********************************************************************
* dpulab - pull AB from data stack
**********************************************************************
dpulab
	sts	ssave	* save S
	lds	datasp	* load data stack pointer
	pula		* pull ACC A from data stack
	pulb		* pull ACC B from data stack
	sts	datasp	* save data stack pointer
	lds	ssave	* restore S
	rts

**********************************************************************
* negab - negate and return the 16-bit value in AB
**********************************************************************
negab
	comb		* 1s complement LSB
	coma		* 1s complement MSB
	addb	#1	* +1
	adca	#0	* propagate carry
.negab	rts

**********************************************************************
* val10x - multiply AB by 10 and return the result
**********************************************************************
val10x
	stx	xsave
	ldx	#10
	staa	absave	* save AB to temp area
	stab	absave+1
	clra
	clrb
.xloop	addb	absave+1	* multiply by repeated addition of AB
	adca	absave
	dex
	bne	.xloop
	ldx	xsave
	rts

**********************************************************************
* val16x - multiply AB by 16 and return the result
**********************************************************************
val16x
	stx	xsave
	ldx	#4
	clc
.x16p	rolb
	rola
	dex
	bne	.x16p
	ldx	xsave
	rts

**********************************************************************
* dsrc - D (disassemble source) command
**********************************************************************
.dsrel	ldaa	#'$'
	jsr	ECHO
	inx
	clra
	ldab	,x	* AB = first operand byte
	bpl	.dntng
	ldaa	#$FF	* sign extend AB
.dntng	addb	prgctr+1	* AB += prgctr
	adca	prgctr
	addb	#2	* AB += 2
	adca	#0
	jsr	PRBYTE
	tba
	jsr	PRBYTE
	jmp	.nxopc
*--------------------------------------------------------------------
dsrc
	clr	fwdrok	* disallow forward references
	ldaa	#'@'
	jsr	ECHO
	ldx	#lnbuf
	jsr	gets	* read disassembly address into lnbuf
	ldx	#lnbuf
	jsr	rdexpr	* returns expr in AB, or Z=1 if none
	beq	dsrc
	staa	prgctr	* store disassembly address in prgctr
	stab	prgctr+1
	ldx	prgctr	* X = prgctr
.dsopc	ldaa	,x	* read next opcode
	bsr	opcmne	* get mnemonic and addressing mode in AB
	tsta		* test mnemonic
	beq	.dsrc	* if illegal instruction, exit
	stx	prgctr	* save X
	jsr	idxmne	* get mnemonic name in X
	ldaa	prgctr
	jsr	PRBYTE
	ldaa	prgctr+1
	jsr	PRBYTE
	jsr	outsp
	bsr	outmne	* print mnemonic at X
	ldx	prgctr	* restore X
	cmpb	#accinh	* 1-byte instruction?
	beq	.nxopc
	jsr	outsp
	cmpb	#rel	* PC-relative operand?
	beq	.dsrel
	bitb	#imm16	* test for immediate operand
	beq	.dntim
	ldaa	#'#'
	jsr	ECHO
.dntim
	ldaa	#'$'
	jsr	ECHO
	inx		* consume opcode
	ldaa	,x	* read first operand byte
	jsr	PRBYTE	* print it
	cmpb	#imm16	* 3-byte instruction?
	beq	.opc3b	* if yes, see below
	cmpb	#ext	* 3-byte instruction?
	beq	.opc3b	* if yes, see below
	cmpb	#idx	* else, 2-byte instruction idx mode?
	bne	.dntix
	ldaa	#','
	jsr	ECHO
	ldaa	#'X'
	jsr	ECHO
.dntix	bra	.nxopc
*--------------------------------------------------------------------
.opc3b	inx		* consume operand byte
	ldaa	,x	* read second operand byte
	jsr	PRBYTE	* print it
.nxopc	inx		* consume operand byte
	jsr	newline
	ldaa	KBD_CR	* key pressed?
	bpl	.dsopc	* if not, loop
.dsrc	rts

**********************************************************************
* outmne - print mnemonic name at X (always prints 4 characters)
**********************************************************************
outmne
	ldaa	0,x	* print mnemonic
	jsr	ECHO
	ldaa	1,x
	jsr	ECHO
	ldaa	2,x
	jsr	ECHO
	ldaa	3,x
	jmp	ECHO	* call ECHO and return

**********************************************************************
* opcmne - lookup opcode (ACC A) and return
*          mnemonic index (ACC A) and addressing mode (ACC B)
**********************************************************************
opcmne
	stx	xsave	* save X
	tab		* AB = opcode
	clra
	bsr	mul2ab	* AB = offset (opcode * 2)
	addb	#opcode%$100	* AB += opcode table base
	adca	#opcode/$100
	staa	absave	* X = AB
	stab	absave+1
	ldx	absave
	ldaa	0,x	* ACC A = mnemonic
	ldab	1,x	* ACC B = addressing mode
	ldx	xsave	* restore X
	rts

**********************************************************************
* idxmne - lookup mnemonic given index (ACC A) and return in X
**********************************************************************
idxmne
	pshb		* save B
	suba	#1	* convert to zero-based index
	tab		* AB = index
	clra
	bsr	mul4ab	* AB = offset (opcode * 4)
	addb	#mnemon%$100	* AB += mnemonic table base
	adca	#mnemon/$100
	staa	absave	* X = AB
	stab	absave+1
	ldx	absave
	pulb		* restore B
	rts


**********************************************************************
* mul4ab,mul2ab - multiply AB by 4,2
**********************************************************************
mul4ab
	aslb		* shift left lower
	rola		* shift left upper
mul2ab
	aslb		* shift left lower
	rola		* shift left upper
	rts

* XXX hack to print resulting values
prntab
	psha
	pshb
	stx	xsave
	ldx	#dbgstr
	jsr	puts
	jsr	PRBYTE	* print ACC A
	jsr	outsp
	tba
	jsr	PRBYTE	* print ACC B
	jsr	newline
	ldx	xsave
	pulb
	pula
	rts
