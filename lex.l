%{
	#include "yacc.tab.h"
	#include <stdlib.h>
	#include <string.h>
	void yyerror(char *);
	int yylineno;
%}

%%
"//".* {return BLANK;};
"/*".*"*/" {return BLANK;};
[0-9]+ { yylval = atoi(yytext); return INTEGER; }
"int"|"String" return *yytext;
[Ii][Nn][Tt ].* my_return ("int falsch geschrieben");
[Ss][Tt][Rr][Ii][Nn][Gg ].* my_return ("String falsch geschrieben");
[a-zA-Z]+ { yylval = strdup(yytext); return ID; }
[-+*/()=] return *yytext;
";"        { return *yytext; printf ("\n"); yylineno++; };
[ \t] ; /* skip whitespace */
. my_return ("unknown symbol");
%%

int my_return(char *token)
{
    printf ("\nZeile %d | ", yylineno);
    printf("%s", token);
}

int yywrap(void) {
	return 1;
}