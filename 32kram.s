**********************************************************************
*  32kram.s
*  asm68
*
*  Created by Tim McIntosh on 12/21/25.
**********************************************************************

**********************************************************************
* Memory layout
**********************************************************************

srcbuf	equ	$2000	* source code storage (NUL,NUL terminated)

LOADDR	equ	$7100	* program load address

GBLBOT	equ	$6500	* bottom of global symbol table
SYMTAB	equ	$6d00	* local/global symbol table boundary
FWDREF	equ	$6e00	* Forward reference table (grows up)
FWDEND	equ	$7100	* End of forward reference table
