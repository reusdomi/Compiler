%{
	#include<stdio.h>
	int yylex(void);
	void yyerror(char *);
%}

%token INTEGER ID BLANK

%%
program: program expr ';' { printf("\n"); }
	| ;
expr:	ID		{ printf("%s", $1); }
	|bcalc		{ printf("%d", $1); }
	|expr expr	{ ; }
	|decl
	|BLANK
	;		
bcalc:	INTEGER			{ $$ = $1; }
	| bcalc '+' bcalc 	{ $$ = $1 + $3; }
	| bcalc '-' bcalc 	{ $$ = $1 - $3; }
	| bcalc '*' bcalc 	{ $$ = $1 * $3; }
	| bcalc '/' bcalc 	{ if($3 == 0)
					yyerror("durch null teilen geht nicht");
				  else
					$$=$1 / $3;
				}
	| '-' bcalc		{ $$ = -$2; }
	| '(' bcalc ')'		{ $$ = $2; }
	;
decl:	'int' ID '=' bcalc	{printf("int %s = %d", $2, $4);}
	| 'String' ID '=' ID	{printf("String %s = %s", $2, $4);}
	;
%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

int main(void) {
	yyparse();
	return 0;
}