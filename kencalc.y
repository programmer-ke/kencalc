%{

#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>

jmp_buf begin;
double mem[26];         // memory for variables 'a' ... 'z'

int yylex(void);
void yyerror(char *s);
void warning(char *s, char *t);
void fpecatch(int i);
void execerror(char *s, char *t);

extern char *progname;
extern int lineno;
%}
%union {                // stack type
    double val;         // actual value
    int index;          // index into mem[]
}
%token	<val>		NUMBER   // when NUMBER is returned from yylex, its value is in val
%token	<index>		VAR      // when VAR is returned from yylex, its value is in index
%type	<val>		expr     // expression is the val member of the union

%right '='              // right associative
			// left associative order of increasing precedence
%left  '+' '-'
%left  '*' '/'
%left UNARYMINUS
%left UNARYPLUS
%%
list://		nothing
	|	list '\n'
	|	list expr '\n' { printf("\t%.8g\n", $2); }
	|	list error '\n' { yyerrok; } // If a syntax error is encountered, skip to end of line and reset error status
	;
expr:		NUMBER                    { $$ = $1; }
	|	VAR                       { $$ = mem[$1]; }
	|	VAR '=' expr              { $$ = mem[$1] = $3; }
	|	'-' expr %prec UNARYMINUS { $$ = -$2; }
	|	'+' expr %prec UNARYPLUS  { $$ = +$2; }
	|	expr '+' expr { $$ = $1 + $3; }
	|	expr '-' expr { $$ = $1 - $3; }
	|	expr '*' expr { $$ = $1 * $3; }
	|	expr '/' expr {
                   if ($3 == 0.0)
	              execerror("division by zero", "");
                   $$ = $1 / $3; }
	|	'(' expr ')'  { $$ = $2; }
	;
%%
		// end of grammar
char *progname;
int lineno = 1;

int main(int argc, char *argv[]) {

    progname = argv[0];
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
    if (islower(c)) {
	yylval.index = c - 'a';   // ascii index
	return VAR;
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
