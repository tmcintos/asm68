**********************************************************************
*  8ka1rom.s
*  asm68
*
*  Created by Tim McIntosh on 1/6/2026.
**********************************************************************

**********************************************************************
* Memory layout
**********************************************************************

srcbuf	equ	$0500	* source code storage (NUL,NUL terminated)

LOADDR	equ	$e000	* program load address

GBLBOT	equ	$0d00	* bottom of global symbol table
SYMTAB	equ	$0e00	* local/global symbol table boundary
FWDREF	equ	$0f00	* Forward reference table (grows up)
FWDEND	equ	$1000	* End of forward reference table
