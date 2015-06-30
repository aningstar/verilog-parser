lex:
	lex lexic.l
	gcc lex.yy.c -lfl
	./a.out < example.v
