parser: lexic.l verilog_parser.y
	bison -d verilog_parser.y
	lex lexic.l
	gcc lex.yy.c verilog_parser.tab.c -lfl -o $@
	./$@ < grammar_example.v

clean: 
	rm lex.yy.c
	rm verilog_parser.tab.h
	rm verilog_parser.tab.c
	rm parser