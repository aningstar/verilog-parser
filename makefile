run: build
	./verilog_parser

build: main/*.c parser/lib/*.c
	cd main/ && \
	gcc `pkg-config --cflags gtk+-3.0` -o \
	../verilog_parser \
	../parser/lib/*.c \
	*.c \
	-lfl \
	-pthread \
	`pkg-config --libs gtk+-3.0`

parser: 
	cd parser/ && $(MAKE)

clean:
	rm verilog_parser
	cd parser/ && $(MAKE) clean
