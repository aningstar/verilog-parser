BC = bison
LC = lex
RM = rm
BFLAGS = -d

all:  
	$(BC) $(BFLAGS) src/verilog_parser.y
	$(LC) src/lexic.l
	mv *.c lib/
	mv *.h lib/

clean:
	$(RM) lib/verilog_parser.*
	$(RM) lib/lex.yy.c
