**********************************************************************
*  data.s
*  asm68
*
*  Created by Tim McIntosh on 12/6/25.
**********************************************************************

**********************************************************************
* constants
**********************************************************************

* field widths (nul-terminated)
fields	fcb	6,4,14,9	* label,mnemonic,args,comment

hello	fcc	"asm68 v0.1"
	fcb	CR,NUL
bye	fcc	"bye"
	fcb	CR,MPRMPT	* fake monitor prompt
	fcb	CR,NUL
error	fcc	"error "
	fcb	NUL
dbgstr	fcc	"debug: "
	fcb	NUL

binops
	fcb	'+'
	fdb	opadd
	fcb	'-'
	fdb	opsub
	fcb	'&'
	fdb	opand
	fcb	'|'
	fdb	opor
	fcb	'^'
	fdb	opeor
	fcb	'*'
	fdb	opmult
	fcb	'/'
	fdb	opdiv
	fcb	'%'
	fdb	opmod
	fcb	NUL	* end of list

*--------------------------------------------------------------------
* Command table
*--------------------------------------------------------------------
cmds
	fcb	'a'	* Assemble
	fdb	asrc
	fcb	'd'	* Disassemble
	fdb	dsrc
	fcb	'l'	* List
	fdb	lsrc
	fcb	'n'	* New
	fdb	nsrc
	fcb	NUL	* end of commands
