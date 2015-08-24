all: testcases grammar_examples

testcases: parser
	cd testcases && $(MAKE)

grammar_examples: parser
	cd grammar_examples && $(MAKE)

parser: lexic.l verilog_parser.y
	bison -d -v verilog_parser.y
	lex lexic.l
	gcc lex.yy.c verilog_parser.tab.c -lfl -o verilog_parser

clean: 
	rm lex.yy.c
	rm verilog_parser.tab.h
	rm verilog_parser.tab.c
	rm verilog_parser.output
	rm verilog_parser
