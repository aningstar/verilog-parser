all: parser
	./verilog_parser < constant_declarations_grammar.v
	./verilog_parser < variable_declarations_grammar.v
	./verilog_parser < net_declarations_grammar.v
	./verilog_parser < port_declarations_grammar.v
	./verilog_parser < grammar_example.v

constant_declarations: parser
	./verilog_parser < constant_declarations_grammar.v

variable_declarations: parser
	./verilog_parser < variable_declarations_grammar.v

net_declarations: parser
	./verilog_parser < net_declarations_grammar.v

port_declarations: parser
	./verilog_parser < port_declarations_grammar.v

grammar_example: parser
	./verilog_parser < grammar_example.v

example: parser
	./verilog_parser < example.v

parser: lexic.l verilog_parser.y
	bison -d verilog_parser.y
	lex lexic.l
	gcc lex.yy.c verilog_parser.tab.c -lfl -o verilog_parser

clean: 
	rm lex.yy.c
	rm verilog_parser.tab.h
	rm verilog_parser.tab.c
	rm verilog_parser
