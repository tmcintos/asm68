SRCROOT ?= .
DSTROOT ?= $(SRCROOT)

VPATH = $(SRCROOT)

# see https://github.com/tmcintos/motorola-6800-assembler
AS	= /usr/local/bin/as0
ASFLAGS	= -l cre c s # list with cycle count, crossref & symbol table; note as0 allows '-' only on first flag

SRCS	= defs.s start.s opcode.s data.s asm68.s binop.s mult16.s div16.s setjmp.s

LAYOUTS	= w68ram w68rom 32kram 8ka1rom 8ka1ram

.SUFFIXES: .s19 .bin
.PRECIOUS: %.s19

.s.s19:
	$(AS) $^ -o $@ $(ASFLAGS)
	ORG=`grep LOADDR $< | cut -f3 | cut -c2-`; \
	sed -E -e 's/\t[*].*$$//' $^ | grep -v '^\*' | grep -v '^$$' > $*-unified.s
# note as0 requires flags after files

.s19.bin: 
	mot2bin -o $@ -p 0 $< | tee $*.mot2bin
	LOAD=`grep 'Binary file start = ' $*.mot2bin | cut -w -f5`; \
	bintomon -l 0x$$LOAD $@ > $*.hex

.DEFAULT: all

all: $(LAYOUTS:=.bin)
	if command -v -- pbcopy >/dev/null 2>&1; then pbcopy < $(<:.bin=.hex); fi

$(LAYOUTS:=.s19): $(SRCS)

clean:
	rm -f *.bin *.hex *.s19 *.mot2bin $(LAYOUTS:=-unified.s)
