%{

#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>
#include "kencalc.h"

jmp_buf begin;

int yylex(void);
void yyerror(char *s);
void warning(char *s, char *t);
void fpecatch(int i);
void execerror(char *s, char *t);

extern double Pow();
extern char *progname;
extern int lineno;
%}
%union {                // stack type
    double val;         // actual value
    Symbol *sym;        // symbol table pointer
}
%token	<val>		NUMBER   // when returned from yylex, its value is in val
%token	<sym>		VAR BLTIN UNDEF  // when returned from yylex, its value is in sym
%type	<val>		expr asgn    // expression/assignment is the val member of the union

%right '='              // right associative
			
%left  '+' '-'          // left associative order of increasing precedence
%left  '*' '/'
%left UNARYMINUS
%left UNARYPLUS
%right '^' //		exponentiation
%%
list://		nothing
	|	list '\n'
	|	list asgn '\n'
	|	list expr '\n' { printf("\t%.8g\n", $2); }
	|	list error '\n' { yyerrok; } // If a syntax error is encountered, skip to end of line and reset error status
	;
asgn:		 VAR '=' expr { $$=$1->u.val=$3; $1->type = VAR; }
	;
expr:		NUMBER
	|	VAR  { if ($1->type == UNDEF) execerror("undefined variable", $1->name);
                       $$ = $1->u.val; }
	|	asgn
	|	BLTIN '(' expr ')' { $$ = (*($1->u.ptr))($3); }
	|	expr '+' expr { $$ = $1 + $3; }
	|	expr '-' expr { $$ = $1 - $3; }
	|	expr '*' expr { $$ = $1 * $3; }
	|	expr '/' expr {
                   if ($3 == 0.0)
	              execerror("division by zero", "");
                   $$ = $1 / $3; }
	|	expr '^' expr { $$ = Pow($1, $3);  }
	|	'(' expr ')'  { $$ = $2; }
	|	'-' expr %prec UNARYMINUS { $$ = -$2; }
	|	'+' expr %prec UNARYPLUS  { $$ = +$2; }

	;
%%
		// end of grammar
char *progname;
int lineno = 1;

int main(int argc, char *argv[]) {

    progname = argv[0];
    init();
    setjmp(begin);  // store current stack information
    signal(SIGFPE, fpecatch);  // set handler for floating point errors
    return yyparse();
}

/* yylex: processes a token
 *
 * Returns the token type and if a number, sets the value in yylval
 * Called by yyparse
 */
int yylex(void) {
    int c;
    while ((c=getchar()) == ' ' || c == '\t')
	;
    if (c == EOF)
	return 0;
    if (c == '.' || isdigit(c)) {  // number
	ungetc(c, stdin);
	scanf("%lf", &yylval.val);
	return NUMBER;
    }
    if (isalpha(c)) {
	Symbol *s;
	char sbuf[100], *p = sbuf;
	do {
	    *p++ = c;
	} while ((c = getchar()) != EOF && isalnum(c));
	ungetc(c, stdin);
	*p = '\0';
	if ((s=lookup(sbuf)) == 0)
	    s = install(sbuf, UNDEF, 0.0);
	yylval.sym = s;
	return s->type == UNDEF ? VAR : s->type;
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

// Recover from runtime error
void execerror(char *s, char *t) {
    warning(s, t);
    longjmp(begin, 0);
}

// Catch floating point exceptions
void fpecatch(int i) {
    execerror("floating point exception", (char *) 0);
}
