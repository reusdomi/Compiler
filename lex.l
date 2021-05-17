%{
	#include "yacc.tab.h"
	#include <stdlib.h>
	#include <string.h>
	void yyerror(char *);
%}

%%
"//".* {return BLANK;};
"/*".*"*/" {return BLANK;};
[0-9]+ { yylval = atoi(yytext); return INTEGER; }
"int"|"String" return *yytext;
[a-zA-Z]+ { yylval = strdup(yytext); return ID; }
[-+*/()=] return *yytext;
";"       { newLine(); return *yytext; printf ("\n"); };
[ \t] ; /* skip whitespace */
. my_return ("unknown symbol");
%%

int yywrap(void) {
	return 1;
}