all: parser
	./verilog_parser < grammar_examples/bit_selects.v
	./verilog_parser < grammar_examples/constant_declarations_grammar.v
	./verilog_parser < grammar_examples/variable_declarations_grammar.v
	./verilog_parser < grammar_examples/net_declarations_grammar.v
	./verilog_parser < grammar_examples/port_declarations_grammar.v
	./verilog_parser < grammar_examples/grammar_example.v

bit_selects: parser
	./verilog_parser < grammar_examples/bit_selects.v

constant_declarations: parser
	./verilog_parser < grammar_examples/constant_declarations_grammar.v

variable_declarations: parser
	./verilog_parser < grammar_examples/variable_declarations_grammar.v

net_declarations: parser
	./verilog_parser < grammar_examples/net_declarations_grammar.v

port_declarations: parser
	./verilog_parser < grammar_examples/port_declarations_grammar.v

grammar_example: parser
	./verilog_parser < grammar_examples/grammar_example.v

example: parser
	./verilog_parser < grammar_examples/example.v

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
