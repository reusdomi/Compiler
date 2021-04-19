
%{
#include "yacc.tab.h"
#include <stdlib.h>
void yyerror(char *);
%}
%%
[0-9]+ { yylval = atoi(yytext);
return INTEGER; }
[a-zA-Z]+ {yylval = strdup(yytext);return ID; }
[-+*/\n] return *yytext;
[ \t] ; /* skip whitespace */
. yyerror ("invalid character");
%%
int yywrap(void) {
return 1;
}