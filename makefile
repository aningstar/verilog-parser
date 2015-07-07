port_declarations: parser
	./verilog_parser < port_declarations_grammar.v

grammar_example: parser
	./verilog_parser < grammar_example.v

parser: lexic.l verilog_parser.y
	bison -d verilog_parser.y
	lex lexic.l
	gcc lex.yy.c verilog_parser.tab.c -lfl -o verilog_parser

clean: 
	rm lex.yy.c
	rm verilog_parser.tab.h
	rm verilog_parser.tab.c
	rm verilog_parser
