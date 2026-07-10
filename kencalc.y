%{

#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>
#include "kencalc.h"

jmp_buf begin;

#define code2(c1, c2) code(c1); code(c2)
#define code3(c1, c2, c3) code(c1); code(c2); code(c3)

int yylex(void);
void yyerror(char *s);
void warning(char *s, char *t);
void fpecatch(int i);
void execerror(char *s, char *t);

%}
%union {                // stack type (yylval)
    Inst *inst;         // machine instruction
    Symbol *sym;        // symbol table pointer (yylval.sym)
}
%token	<sym>		VAR BLTIN UNDEF NUMBER  // when returned from yylex, its value is in sym
%type	<inst>		expr asgn    // expression/assignment is the inst member of the union

%right '='              // right associative
			
%left  '+' '-'          // left associative order of increasing precedence
%left  '*' '/'
%left UNARYMINUS
%left UNARYPLUS
%right '^' //		exponentiation
%%
list://		nothing
	|	list '\n'
	|	list asgn '\n' { code2(popop, STOP); return 1; }
	|	list expr '\n' { code2(print, STOP); return 1; }
	|	list error '\n' { yyerrok; } // If a syntax error is encountered, skip to end of line and reset error status
	;
asgn:		 VAR '=' expr { code3(varpush, (Inst)$1, assign); }
	;
expr:		NUMBER  { code2(constpush, (Inst)$1); }
	|	VAR  { code3(varpush, (Inst)$1, eval); }
	|	asgn
	|	BLTIN '(' expr ')' { code2(bltin, (Inst)$1->u.ptr); }
	|	expr '+' expr { code(add); }
	|	expr '-' expr { code(sub); }
	|	expr '*' expr { code(mul); }
	|	expr '/' expr { code(divop); }
	|	expr '^' expr { code(power);  }
	|	'(' expr ')'  { $$ = $2; }
	|	'-'expr %prec UNARYMINUS { code(negate); }
	|	'+' expr %prec UNARYPLUS  { }

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
    for (initcode(); yyparse(); initcode())
	// loop and execute generated programs as long as yyparse returns 1;
	execute(prog);
    return 0;
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
	double d;
	ungetc(c, stdin);
	scanf("%lf", &d);
	yylval.sym = install("", NUMBER, d);
	return NUMBER;
    }
    if (isalpha(c)) {
	Symbol *s;
	char sbuf[100], *p = sbuf, *end = sbuf + sizeof(sbuf) - 1;
	do {
	    if (p >= end)
		execerror("identifier too long", (char *) 0);
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
