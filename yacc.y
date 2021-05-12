%{
	#include<stdio.h>
	#include<limits.h>
	#include<stdlib.h>
	int yylex(void);
	void yyerror(char *);
	struct decla {
		char *name;
		char *type;
		struct expres *value;
		struct decla *next;
	} ;
	struct decla *declar = NULL;
	struct expres {
		char *type;
		int value;
		char *sValue;
	};
	struct decla * decl_create( char *name,
	char *type,
	struct expres *value,
	struct decla *next )
	{
		struct decla *d = malloc(sizeof(*d));
		d->name = name;
		d->type = type;
		d->value = value;
		d->next = next;
		return d;
	}
struct expres * expr_create_string_literal( const char *str ){
	struct expres *e = malloc(sizeof(*e));
	e->type = "String";
	e->value = INT_MIN;
	e->sValue = *str;
	return e;
}
struct expres * expr_create_integer_literal( int i ){
	struct expres *e = malloc(sizeof(*e));
	e->type = "int";
	e->value = i;
	e->sValue = NULL;
	return e;
}
void createDecl(char *type, struct expres *e, char *name){
	if (!declar){
		declar = malloc(sizeof(*declar));
		declar = decl_create( name, type, e, NULL );
	}
	else{
		struct decla *dec_temp = malloc(sizeof(*dec_temp));
		dec_temp = declar;
		while(dec_temp->next && strcmp(dec_temp->name, name) != 0){
			printf("While\nVar %s: %d\n", dec_temp->name, dec_temp->value->value);
			dec_temp=dec_temp->next;
		}
		if(strcmp(dec_temp->name, name) == 0){
			printf("Variablenname bereits vergeben!\n");
		}
		else{
	  		dec_temp->next = decl_create( name, type, e, NULL );
			printf("Else\n");
		}
	}

}
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
decl:	'int' ID '=' bcalc	{createDecl("int",expr_create_integer_literal($4), $2);printf("int %s = %d", $2, $4);}
	| 'String' ID '=' ID	{char *s = $4; createDecl("String",expr_create_string_literal(s), $2);printf("String %s = %s", $2, $4);}
	;
%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}


int main(void) {
	yyparse();
	return 0;
}