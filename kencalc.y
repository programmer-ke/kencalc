%{
#define YYSTYPE double  // data type of the yacc stack
#include <stdio.h>
#include <ctype.h>

int yylex(void);
void yyerror(char *s);
void warning(char *s, char *t);

extern char *progname;
extern int lineno;
%}
%token NUMBER
%left  '+' '-'  //	left associative, same precedence
%left  '*' '/' //	left associative, higher precedence
%%
list://		nothing
	|	list '\n'
	|	list expr '\n' { printf("\t%.8g\n", $2); }
	;
expr:		NUMBER { $$ = $1; }
	|	expr '+' expr { $$ = $1 + $3; }
	|	expr '-' expr { $$ = $1 - $3; }
	|	expr '*' expr { $$ = $1 * $3; }
	|	expr '/' expr { $$ = $1 / $3; }
	|	'(' expr ')'  { $$ = $2; }
	;
%%
		// end of grammar
char *progname;
int lineno = 1;

int main(int argc, char *argv[]) {
    progname = argv[0];
    yyparse();
}

/* yylex: processes a token
 *
 * Returns the token type and if a number, sets the value in yylval
 * Called by yyparse
 */
int yylex() {
    int c;
    while ((c=getchar()) == ' ' || c == '\t')
	;
    if (c == EOF)
	return 0;
    if (c == '.' || isdigit(c)) {  // number
	ungetc(c, stdin);
	scanf("%lf", &yylval);
	return NUMBER;
    }
    if (c == '\n')
	lineno++;
    return c;
}

/*
 * yyerror: called for yacc syntax error
 */
void yyerror(char *s) {
    warning(s, (char *) 0);
}


void warning(char *s, char *t) { // print warning message
    fprintf(stderr, "%s: %s", progname, s);
    if (t)
	fprintf(stderr, " %s", t);
    fprintf(stderr, " near line %d\n", lineno);
}  
