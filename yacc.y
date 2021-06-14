%{
	#include<stdio.h>
	#include<limits.h>
	#include<stdlib.h>
	int yylex(void);
	int yylineno;
	void yyerror(char *);

	struct integer{
		char* node_type;
		int value;
	};

	struct decla {
		char *name;
		char *type;
		struct expres *value;
		struct decla *next;
	};
	struct decla *declar = NULL;
	struct expres {
		char *type;
		struct integer *value;
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
	struct expres * expr_create_integer_literal( struct integer *i ){
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
			if(dec_temp->value->value->value != INT_MIN){
				return dec_temp->value->value->value;
			}
			else{
				my_return("Variable besitzt noch keinen Wert!");
			}
		}
	}

	void assign(int v, char *name){
		struct decla *dec_temp = malloc(sizeof(*dec_temp));
		dec_temp = declar;

		int found = 0;
		
		while(dec_temp){
		
			if(strcmp(dec_temp->name, name) == 0){
				//printf("value before : %i \n", dec_temp->value->value);
				//printf("value: %i \n", v);
				dec_temp->value->value = v;
				printf("%s = %i", dec_temp->name, dec_temp->value->value);
				//printf("seems to work \n");
				//printf("t->value: %i \n", dec_temp->value->value);

				found = 1;
			}
			
			if(dec_temp->next){
				dec_temp =dec_temp->next;
			}else{
				break;
			}
		}

		if(found == 0) {
			printf("Keine solche Variable enthalten \n");
		}
	}

	void printVars(){
		if(!declar){
			printf("\nKeine Variablen in Symbolliste gespeichert");
		}
		else{
			struct decla *dec_temp = declar;
			printf("\nTyp\tName\tWert\n");
			do{
				if(strcmp(dec_temp->type, "String") == 0){
					printf("%s\t%s\t%s\n", dec_temp->type, dec_temp->name, dec_temp->value->sValue);
				}
				else{
					printf("%s\t%s\t%d\n", dec_temp->type, dec_temp->name, dec_temp->value->value->value);
				}
				dec_temp = dec_temp->next;
			}while(dec_temp);
		}
	}

	/* -------------- parsing tree ----------------- */
	
	struct expression;
	struct expression *root = NULL;

	struct calculation{
		char* node_type;
		struct calculation *left;
		struct calculation *right;
		struct integer *value;
	};
	

	struct calculation *create_calculation(char* nodetype, struct calculation *c1, struct calculation *c2, struct integer *val){
		struct calculation *c = malloc(sizeof(struct calculation));
		c->node_type = nodetype;
		c->left = c1;
		c->right = c2;
		c->value = val;
		
		printf("%s",c->node_type);
		return c;
	}

	struct integer  *create_integer(char* nodetype, int val){
		struct integer *i = malloc(sizeof(struct integer));
		i->node_type = nodetype;
		i->value = val;
		printf("%s",i->node_type);
		printf("%d",i->value);
		return i;
	}
	struct comparison{
		char* node_type;
		struct calculation *left;
		struct calculation *right;
	};
	struct comparison *create_comparison(char* node_type,struct calculation *left,struct calculation *right){
		struct comparison *c = malloc(sizeof(struct comparison));
		c->node_type = node_type;
		c->left = left;
		c->right = right;
		
		printf("%s",c->node_type);
		return c;
	}

	struct condition{
		char* node_type;
		struct comparison *comp;
		struct expression *exprif;
		struct expression *exprelse;
	};
	struct condition *create_condition(char* node_type,struct comparison *comp,struct expression *exprif,struct expression *exprelse){
		struct condition *c = malloc(sizeof(struct condition));
		c->node_type = node_type;
		c->comp = comp;
		c->exprif = exprif;
		c->exprelse = exprelse;
		
		printf("%s",c->node_type);
		return c;
	}

	struct identifier{
		char* node_type;
		char* value;
	};
	struct identifier *create_identifier(char* node_type,char* value){
		struct identifier *i = malloc(sizeof(struct identifier));
		i->node_type = node_type;
		i->value = value;
		
		printf("%s",i->node_type);
		return i;
	}

	struct print{
		char* node_type;
		struct calculation *calc;
		struct identifier *id;
	};
	struct print *create_print(char* node_type,struct calculation *calc,struct identifier *id){
		struct print *p = malloc(sizeof(struct print));
		p->node_type = node_type;
		p->calc = calc;
		p->id = id;
		
		printf("%s",p->node_type);
		return p;
	}

	struct expression{
		char* node_type;
		struct expression *expr;
		struct condition *cond;
		struct identifier *id;
		struct calculation *calc;
		struct decla *decl;
		struct print *print;
	};
	struct expression *create_expression(char* node_type,
						struct expression *expr,
						struct condition *cond,
						struct identifier *id,
						struct calculation *calc,
						struct decla *decl,
						struct print *print){
		struct expression *e = malloc(sizeof(struct expression));
		e->node_type = node_type;
		e->expr = expr;
		e->cond = cond;
		e->id = id;
		e->calc = calc;
		e->decl = decl;
		e->print = print;
		
		if(!root){
			root = e;
		}

		printf("%s",e->node_type);
		return e;
	}
	

%}

%token INTEGER ID BLANK IF ELSE FOR PRINT


%%
expr:	cond			{ $$ = create_expression("expr",NULL,$1,NULL,NULL,NULL,NULL); }
	|ID ';'			{ $$ = create_expression("expr",NULL,NULL,$1,NULL,NULL,NULL); }
	|bcalc ';'		{ $$ = create_expression("expr",NULL,NULL,NULL,$1,NULL,NULL); }
	|expr expr ';'		{ $$ = create_expression("expr",$1,NULL,NULL,NULL,NULL,NULL); }
	|decl ';'		{ $$ = create_expression("expr",NULL,NULL,NULL,NULL,$1,NULL); }
	|print ';'		{ $$ = create_expression("expr",NULL,NULL,NULL,NULL,NULL,$1); }

	| error '\n'		{my_return("';' expected");}
	| error ';'		{my_return("error in expression");}

	|BLANK
	;
cond:	IF comp expr		{ $$ = create_condition("cond",$2,$3,NULL);}
	|IF comp expr ELSE expr { $$ = create_condition("cond",$2,$3,$5);}
	;
comp:	'(' bcalc '=''=' bcalc ')'	{ $$ = create_comparison("comp",$2,$5);}
	;
print:	PRINT '(' bcalc ')'	{ $$ = create_print("print",$3,NULL); }
	|PRINT '(' ID ')'	{ $$ = create_print("print",NULL,$3); }
	;
bcalc:	ID			{ char *n = $1;$$ = create_integer("int",getValue(n));} 
	| INTEGER		{ $$ = create_integer("int",$1); }
	| bcalc '+' bcalc 	{ $$ = create_calculation("+",$1,$2,NULL); }
	| bcalc '-' bcalc 	{ $$ = create_calculation("-",$1,$2,NULL); }
	| bcalc '*' bcalc 	{ $$ = create_calculation("*",$1,$2,NULL); }
	| bcalc '/' bcalc 	{ if($3 == 0)
					my_return("durch Null teilen geht nicht");
				  else
					$$ = create_calculation("/",$1,$2,NULL);;
				}
	| '-' bcalc		{ $$ = create_calculation("*",create_integer("int",-1),$2,NULL); }
	| '(' bcalc ')'		{ $$ = create_calculation("()",$2,NULL,NULL); }

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
decl:	'int' ID		{char *n = $2;
				createDecl("int",expr_create_integer_literal(create_integer("int",INT_MIN)), n);
				decl_create($2,"int",expr_create_integer_literal(create_integer("int",INT_MIN)),NULL);}
	| 'String' ID		{char *n = $2; createDecl("String",expr_create_string_literal(NULL), n); printf("String %s;", n);}
	| 'int' ID '=' bcalc	{char *n = $2;
				createDecl("int",expr_create_integer_literal($4), n);
				decl_create($2,"int",expr_create_integer_literal($4),NULL);}
	| 'String' ID '=' ID	{char *n = $2; char *v = $4; createDecl("String",expr_create_string_literal(v), n); printf("String %s = %s;", n, v);}
	| ID '=' bcalc		{char *n = $1; assign($3,n);
				decl_create($1,"int",expr_create_integer_literal($3),NULL);}
	
	;
%%

void my_return(char *token) {
	printf ("\nZeile %d | %s;", yylineno, token);
	//exit(1);	//Beendet das Programm
}

void newLine() {
	yylineno++;
	//printVars();
}

void yyerror(char *s) {
	fprintf(stderr, "%s;", s);
}

int main(void) {
	yyparse();
	return 0;
}
