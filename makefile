run: build
	./verilog_parser

build: 
	cd main/ && \
	gcc `pkg-config --cflags gtk+-3.0` -o \
	../verilog_parser main.c frame.c \
	../parser/lib/verilog_parser.tab.c \
	../parser/lib/structures.c \
	../parser/lib/lex.yy.c \
	-lfl \
	`pkg-config --libs gtk+-3.0`

parser: 
	cd parser/ && $(MAKE)

clean:
	rm verilog_parser
	cd parser/ && $(MAKE) clean
