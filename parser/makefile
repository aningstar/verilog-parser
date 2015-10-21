BC = bison
LC = lex
RM = rm
BFLAGS = -d

all:  
	$(BC) $(BFLAGS) src/verilog_parser.y
	$(LC) src/lexic.l
	mv verilog_parser.tab.c lib/
	mv lex.yy.c lib/
	mv *.h lib/
	gcc parser.c lib/*.c -o parser -lfl

clean:
	$(RM) lib/verilog_parser.*
	$(RM) lib/lex.yy.c
