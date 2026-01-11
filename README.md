# asm68

This is an interactive [MC6800](https://en.wikipedia.org/wiki/Motorola_6800) [assembler](https://en.wikipedia.org/wiki/Assembly_language#Assembler) for [WOZNIAC-68](https://apps.apple.com/app/wozniac-68/id6736677781), inspired by [KRUSADER](https://github.com/tmcintos/krusader).

## Usage

The assembler may be run by starting execution at the assembler load address (_e.g., using `F000R` when running from ROM_).

The assembler prints a prompt (`?`) to indicate it is ready to accept a command.

The following commands are supported:

- **N** - input new program
- **L** - list program
- **A** - assemble program
- **D** - disassemble memory

Commands are executed immediately, without the need to enter a carriage return.

## Source Code Format

The assembler is line oriented. A program consists of a sequence of lines, one statement per line. Statements consist of up to four fields (columns):

1. label
2. mnemonic
3. operand
4. comment

A field may be empty. Empty fields at the end of the line may be omitted.

If a field begins with `*`, or if the mnemonic field is empty, the rest of the line is treated as a comment.

When inputting a new program, a space or tab character causes the assembler to advance to the next field, until the end of line is reached. A carriage return causes the assembler to advance to the next line. Escape causes the assembler to exit program entry mode and return to the prompt.

## Limitations

- Parentheses are not allowed in expressions
- There is no operator precedence in expressions; the order evaluation is strictly left-to-right.
- Expressions containing operators may not contain a forward reference.

## Motorola Freeware Cross Assembler Compatibility

The assembler provides a degree of source compatibility with the Motorola Freeware PC-Compatible 8-Bit Cross Assembler for the M6800 (M6800 Freeware Assembler).

Unless otherwise specified, the assembler generally follows the source conventions of the M6800 Freeware Assembler.

### Differences

- Fields must be separated by exactly one tab or space character.
- All expressions evaluated as unsigned 16-bit.
- FCB,FDB do not accept lists containing null items (e.g. `,,`).

### Extensions

- ‘.’ may be used as PC
- `;` may be used instead of `*` to introduce comments
- `\` may be used to continue a line

### Unimplemented directives

- BSZ
- FILL
- OPT
- PAGE
- RMB
- ZMB

### Unimplemented features

- `@` octal prefix
- `%` binary prefix
- `$` in symbol name
- `.` in middle of symbol name
- signed arithmetic, greater than 16 bits
- forward references in FCB directives.

## Caveats

- The following errors are not caught and may produce undefined behavior:
	- Symbol redefinition
	- EQU directive without a label.
	- Undefined symbol referenced in FCB,FDB directive.
	- Use of forward reference in EQU or ORG directives.
	- Source or program buffer overflow.
- Support for signed division removed; tests have NOT been updated.
- `\` is treated as a continuation character only outside of quotes
- `\` at end of a quoted string is treated as a literal character

## Memory Layout

### 8ka1rom variant

Address Range		|	Description
--------------	|	--------------------
`$0000..$00FF`	|	Zero page variables (256B)
`$0100..$01FF`	|	6800 stack (256B)
`$0200..$02FF`	|	Keyboard buffer (256B)
`$0300..$0BFF`	|	Program buffer (2K+256B)
`$0C00..$0DFF`	|	Global symbol table (512B)
`$0E00..$0EFF`	|	Local symbol table (256B)
`$0F00..$0FFF`	|	Forward reference table (256B)
`$E000..$EFFF`	|	Source buffer (4K)
`$F000..$FEFF`	|	Assembler (3.75K)

### 8ka1ram variant

Address Range		|	Description
--------------	|	--------------------
`$0000..$00FF`	|	Zero page variables (256B)
`$0100..$01FF`	|	6800 stack (256B)
`$0200..$02FF`	|	Keyboard buffer (256B)
`$0300..$04FF`	|	Program buffer (512B)
`$0500..$0CFF`	|	Source buffer (2K)
`$0D00..$0DFF`	|	Global symbol table (256B)
`$0E00..$0EFF`	|	Local symbol table (256B)
`$0F00..$0FFF`	|	Forward reference table (256B)
`$E000..$EEFF`	|	Assembler (3.75K)

### w68rom variant

Address Range		|	Description
--------------	|	--------------------
`$0000..$00FF`	|	Zero page variables (256B)
`$0100..$01FF`	|	6800 stack (256B)
`$0200..$02FF`	|	Keyboard buffer (256B)
`$0300..$1FFF`	|	Program buffer (7.25K)
`$2000..$9FFF`	|	Source buffer (32K)
`$A000..$AFFF`	|	Global symbol table (4K)
`$B000..$BFFF`	|	Local symbol table (4K)
`$C000..$CFFF`	|	Forward reference table (4K)
`$F000..$FEFF`	|	Assembler (3.75K)

### w68ram variant

Address Range		|	Description
--------------	|	--------------------
`$0000..$00FF`	|	Zero page variables (256B)
`$0100..$01FF`	|	6800 stack (256B)
`$0200..$02FF`	|	Keyboard buffer (256B)
`$0300..$1FFF`	|	Program buffer (7.25K)
`$2000..$90FF`	|	Source buffer (28.25K)
`$9100..$9FFF`	|	Assembler (3.75K)
`$A000..$AFFF`	|	Global symbol table (4K)
`$B000..$BFFF`	|	Local symbol table (4K)
`$C000..$CFFF`	|	Forward reference table (4K)

### 32kram variant

Address Range		|	Description
--------------	|	--------------------
`$0000..$00FF`	|	Zero page variables (256B)
`$0100..$01FF`	|	6800 stack (256B)
`$0200..$02FF`	|	Keyboard buffer (256B)
`$0300..$1FFF`	|	Program buffer (7.25K)
`$2000..$64FF`	|	Source buffer (17.25K)
`$6500..$6CFF`	|	Global symbol table (2K)
`$6D00..$6DFF`	|	Local symbol table (256B)
`$6E00..$70FF`	|	Forward reference table (768B)
`$7100..$7FFF`	|	Assembler (3.75K)

## Building From Source

### UNIX-like Operating Systems

Building requires the following tools:

- [GNU Make](https://www.gnu.org/software/make/)
- [M6800 Freeware Assembler](https://github.com/tmcintos/motorola-6800-assembler) installed as `/usr/local/bin/as0`
- [This version of Hex2bin-2.5](https://github.com/tmcintos/Hex2bin-2.5) for `mot2bin` command.
- [bintomon](https://github.com/jefftranter/6502/tree/master/util/bintomon) by Jeff Tranter for conversion from binary to wozmon hex listing.
