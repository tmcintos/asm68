**********************************************************************
*  w68ram.s
*  asm68
*
*  Created by Tim McIntosh on 12/21/25.
**********************************************************************

**********************************************************************
* Memory layout
**********************************************************************

srcbuf	equ	$2000	* source code storage (NUL,NUL terminated)

LOADDR	equ	$9100	* program load address

GBLBOT	equ	$a000	* bottom of global symbol table
SYMTAB	equ	$b000	* local/global symbol table boundary
FWDREF	equ	$c000	* Forward reference table (grows up)
FWDEND	equ	$d000	* End of forward reference table
