lex:
	lex lexic.l
	gcc lex.yy.c -lfl
	./a.out < lab5_library_input.v
