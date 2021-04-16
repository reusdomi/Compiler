%option noyywrap
%{
    #include<stdio.h>

    int yylineno;
%}

%%
"if"        my_return ("IF")(;
"then"        my_return ("THEN");
"else"        my_return ("ELSE");

[a-zA-Z]+    my_return ("ID");

0        my_return ("INZEIGER");
[1-9] [0-9]*    my_return ("INZEIGER");

\n        {printf ("\n\n");
        yylineno++; };

[ \t]        ;

-        my_return ("unknown symbol");

%%
/int main()
{

    return 0;
}/

int my_return(char *token)
{
    printf ("\nZeile%d | ", yylineno);
    rintf("%s", token);
}