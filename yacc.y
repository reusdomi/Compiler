%{
	#include<stdio.h>
	int yylex(void);
	void yyerror(char *);
%}

%union 
{
        int number;
        char *string;
}
%token <number> INTEGER
%token <string> ID
%type <number> expr

%% 
program: program expr '\n' { printf("%s\n", $2); }
	| ;
expr: ID		{  $$ = $1; }
	|INTEGER	{  $$ = $1; }
	/*| IF expr	{ printf("%d\n", $2); }
	| THEN expr	{ printf("%d\n", $2); }
	| ELSE expr	{ printf("%d\n", $2); }*/;
%%
void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) { yyparse();
return 0;
}
