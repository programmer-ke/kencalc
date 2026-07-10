/* code.c - machine definition for code generation */

#include <stdio.h>
#include "kencalc.h"
#include "y.tab.h"

// the instruction storage
Inst prog[NPROG];
Inst *progp; // next free spot for code gen
static Inst *pc; // program counter during operation

// stack
#define NSTACK 256
static Datum stack[NSTACK];
static Datum *stackp; // next free spot in stack

// @notice Resets the code generator
void initcode(void) {
  progp = prog;
  stackp = stack;
}

// @notice Inserts instruction into the next available slot in prog
Inst *code(Inst f) {
  Inst *oprogp = progp;
  if (progp >= &prog[NPROG]) 
    execerror("program too big", (char *) 0);
  *progp++= f;
  return oprogp;
}

// @notice Push datum to the top of the stack
void push(Datum d) {
  if (stackp >= &stack[NSTACK])
    execerror("stack overflow", (char *) 0);
  *stackp++ = d;
}

// @notice Pops datum from the top of the stack
Datum pop(void) {
  if (stackp <= stack)
    execerror("stack underflow", (char *) 0);
  return *--stackp;
}

// @notice Executes instructions until sentinel (STOP)
void execute(Inst *p) {
  for (pc = p; *pc != STOP;)
    (*(*pc++))();
}

// @notice Pushes a constant number onto the stack
void constpush(void) {
  Datum d;
  d.val = ((Symbol *)*pc++)->u.val;
  push(d);
}

// @notice Pushes a variable onto the stack
void varpush(void) {
  Datum d;
  d.sym = (Symbol *)(*pc++);
  push(d);
}

// @notice Evaluates a variable on top of the stack into its value
void eval(void) {
  Datum d;
  d = pop();
  if (d.sym->type == UNDEF)
    execerror("undefined variable", d.sym->name);
  d.val = d.sym->u.val;
  push(d);
}


// @notice Adds two constants
void add(void) {
  Datum d1, d2;
  d2 = pop();
  d1 = pop();
  d1.val += d2.val;
  push(d1);
}


// @notice Subtracts two constants
void sub(void) {
  Datum d1, d2;
  d2 = pop();
  d1 = pop();
  d1.val -= d2.val;
  push(d1);
}


// @notice Multiplies two constants
void mul(void) {
  Datum d1, d2;
  d2 = pop();
  d1 = pop();
  d1.val *= d2.val;
  push(d1);
}

// @notice Divides two constants
void divop(void) {
  Datum d1, d2;
  d2 = pop();
  d1 = pop();
  if (d2.val == 0.0)
    execerror("division by zero", "");
  d1.val /= d2.val;
  push(d1);
}

// @notice Negates a constant
void negate(void) {
  Datum d;
  d = pop();
  d.val = -d.val;
  push(d);
}


// @notice Exponentiates a constant
void power(void) {
  Datum d1, d2;
  d2 = pop();
  d1 = pop();
  d1.val = Pow(d1.val, d2.val);
  push(d1);
}

// @notice Assigns a constant to a variable
void assign(void) {
  Datum d1, d2;
  d1 = pop(); // symbol pointer
  d2 = pop(); // value to assign
  if (d1.sym->type != VAR && d1.sym->type != UNDEF)
    execerror("assignment to non-variable", d1.sym->name);
  d1.sym->u.val = d2.val;
  d1.sym->type = VAR;
  push(d2); // push back value so assignment can be used as expression
}

// @notice Calls built-in function with argument
void bltin(void) {
  Datum d;
  d = pop();
  d.val = (*(double (*)(double))(*pc++))(d.val);
  push(d);
}


// @notice prints the item at top of the stack
void print(void) {
  Datum d;
  d = pop();
  printf("\t%.8g\n", d.val);
}

// @notice Pops off the top item from the stack
void popop(void) {
  pop();  // pop off the top item
}
