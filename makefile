
parser: lexic.l verilog_parser.y
	bison -d -v verilog_parser.y
	lex lexic.l
	gcc lex.yy.c verilog_parser.tab.c structures.c main.c -lfl -o verilog_parser

gui: frame.c
	gcc `pkg-config --cflags gtk+-3.0` -o frame frame.c `pkg-config --libs gtk+-3.0`

debug: lexic.l verilog_parser.y
	bison -d -v verilog_parser.y
	lex lexic.l
	gcc -Wall -g lex.yy.c verilog_parser.tab.c structures.c main.c -lfl -o verilog_parser

clean: 
	rm lex.yy.c
	rm verilog_parser.tab.h
	rm verilog_parser.tab.c
	rm verilog_parser.output
	rm verilog_parser
