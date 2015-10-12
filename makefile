run:
	./verilog_parser

build: 
	cd main/ && \
	gcc `pkg-config --cflags gtk+-3.0` -o ../verilog_parser main.c frame.c `pkg-config --libs gtk+-3.0`

parser: 
	cd parser/ && $(MAKE)

clean:
	rm verilog_parser
	cd parser/ && $(MAKE) clean
