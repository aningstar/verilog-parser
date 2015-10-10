parser: 
	cd parser/ && $(MAKE)

gui: 
	cd main/ && \
	gcc `pkg-config --cflags gtk+-3.0` -o frame frame.c `pkg-config --libs gtk+-3.0`

clean:
	cd parser/ && $(MAKE) clean
