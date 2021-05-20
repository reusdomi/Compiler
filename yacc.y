%{
	#include<stdio.h>
	#include<limits.h>
	#include<stdlib.h>
	int yylex(void);
	int yylineno;
	void yyerror(char *);
	struct decla {
		char *name;
		char *type;
		struct expres *value;
		struct decla *next;
	};
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
				/*printf("While\nVar %s: %d\n", dec_temp->name, dec_temp->value->value);*/
				dec_temp=dec_temp->next;
			}
			if(strcmp(dec_temp->name, name) == 0){
				my_return("Variablenname bereits vergeben!");
			}
			else{
	  			dec_temp->next = decl_create( name, type, e, NULL );
				/*printf("Else\n");*/
			}
		}
	}
	int checkString(char *name){
		struct decla *dec_temp = malloc(sizeof(*dec_temp));
		dec_temp = declar;
		while(dec_temp->next){
			if(strcmp(dec_temp->name, name) == 0){
				if(strcmp(dec_temp->type, "String")==0){
					return 1;
				}
				else{return 0;}
			}
			dec_temp=dec_temp->next;
		}
		my_return("Variable noch nicht deklariert");
		return 0;
	}
	
	int checkInt(char *name){
		struct decla *dec_temp = malloc(sizeof(*dec_temp));
		dec_temp = declar;
		while(dec_temp->next){
			if(strcmp(dec_temp->name, name) == 0){
				if(strcmp(dec_temp->type, "int")==0){
					return 1;
				}
				else{return 0;}
			}
			dec_temp=dec_temp->next;
		}
		if(strcmp(dec_temp->name, name) == 0){
				if(strcmp(dec_temp->type, "int")==0){
					return 1;
				}
				else{
					my_return("Variable vom Typ 'String'!");
					return 0;
				}
		}
		else{
			my_return("Variable noch nicht deklariert");
			return 0;
		}
	}

	int getValue(char *name){
		if(checkInt(name)){
			struct decla *dec_temp = malloc(sizeof(*dec_temp));
			dec_temp = declar;
			while(strcmp(dec_temp->name, name) != 0){
				dec_temp=dec_temp->next;
			}
			if(dec_temp->value->value != INT_MIN){
				return dec_temp->value->value;
			}
			else{
				my_return("Variable besitzt noch keinen Wert!");
			}
		}
	}

	void assign(int v, char *name){
		struct decla *dec_temp = malloc(sizeof(*dec_temp));
		dec_temp = declar;
		
		while(dec_temp){
		
			if(strcmp(dec_temp->name, name) == 0){
				//printf("value before : %i \n", dec_temp->value->value);
				//printf("value: %i \n", v);
				dec_temp->value->value = v;
				//printf("seems to work \n");
				//printf("t->value: %i \n", dec_temp->value->value);
			}else{
				if(!dec_temp->next){printf("Keine solche Variable enthalten \n");}
			}
			
			if(dec_temp->next){
				dec_temp =dec_temp->next;
			}else{
				break;
			}
		}
	}
%}

%token INTEGER ID BLANK

%%
program: program expr ';' {;}
	| ;
expr:	ID ';'		{ printf("\n%s;", $1); }
	|bcalc ';'		{ printf("\n%d;", $1); }
	|expr expr ';'		{ ; }
	|decl ';'

	| error '\n'		{my_return("';' expected");}
	| error ';'		{my_return("error in expression");}

	|BLANK
	;		
bcalc:	ID			{ char *n = $1; $$ = getValue(n);} 
	| INTEGER		{ $$ = $1; }
	| bcalc '+' bcalc 	{ $$ = $1 + $3; }
	| bcalc '-' bcalc 	{ $$ = $1 - $3; }
	| bcalc '*' bcalc 	{ $$ = $1 * $3; }
	| bcalc '/' bcalc 	{ if($3 == 0)
					my_return("durch Null teilen geht nicht");
				  else
					$$=$1 / $3;
				}
	| '-' bcalc		{ $$ = $1; }
	| '(' bcalc ')'		{ $$ = $2; }

	| error '+' bcalc	{my_return("first operand missing");}
	| error '-' bcalc	{my_return("first operand missing");}
	| error '*' bcalc	{my_return("first operand missing");}
	| error '/' bcalc	{my_return("first operand missing");}
	| bcalc '+' error	{my_return("second operand missing");}
	| bcalc '-' error	{my_return("second operand missing");}
	| bcalc '*' error	{my_return("second operand missing");}
	| bcalc '/' error	{my_return("second operand missing");}
	| error bcalc ')'	{my_return("'(' expected");}
	| '(' bcalc error	{my_return("')' expected");}
	;
decl:	'int' ID		{char *n = $2; createDecl("int",expr_create_integer_literal(INT_MIN), n); printf("int %s;", n);}
	| 'String' ID		{char *n = $2; createDecl("String",expr_create_string_literal(NULL), n); printf("String %s;", n);}
	| 'int' ID '=' bcalc	{char *n = $2; createDecl("int",expr_create_integer_literal($4), n); printf("int %s = %d;", n, $4);}
	| 'String' ID '=' ID	{char *n = $2; char *v = $4; createDecl("String",expr_create_string_literal(v), n); printf("String %s = %s;", n, v);}
	| ID '=' bcalc		{char *n = $1; assign($3,n);}
	
	;
%%

void my_return(char *token) {
	printf ("\nZeile %d | %s;", yylineno, token);
	//exit(1);	//Beendet das Programm
}

void newLine() {
	yylineno++;
}

void yyerror(char *s) {
	fprintf(stderr, "%s;", s);
}

int main(void) {
	yyparse();
	return 0;
}