lex:
	lex lexic.l
	gcc lex.yy.c -lfl
	./a.out < example.v

clean: 
	rm lex.yy.c
	rm a.out
