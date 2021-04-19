%{
	#include<stdio.h>
	int yylex(void);
	void yyerror(char *);
%}

%token INTEGER
%token ID

%%
program: program expr '\n' { printf("\n"); }
	| ;
expr:	ID		{ printf("%s", $1); }
	|int		{ printf("%d", $1); }
	|expr expr	{ ; } ;		
int:	INTEGER		{ $$=$1; }
	| int '+' int	{ $$=$1 + $3; }
	| int '-' int	{ $$=$1 - $3; }
	| int '*' int	{ $$=$1 * $3; }
	| int '/' int	{ $$=$1 / $3; } ;
%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

int main(void) {
	yyparse();
	return 0;
}
