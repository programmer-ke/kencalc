#include "kencalc.h"
#include "y.tab.h"
#include <math.h>

extern double Log(double), Log10(double), Exp(double), Sqrt(double), integer(double);

// constants
static struct {
  char *name;
  double cval;
} consts[] = {
  "PI", 3.14159265358979311600,
  "E", 2.71828182845904509080,
  "GAMMA", 0.577215664901532860606,
  "PHI", 1.61803398874989490253,
  "DEG", 57.29577951308232286465,
  0, 0
};

// Builtins
static struct {
  const char *name;
  double (*func)(double);
} builtins[] = {
  "sin", sin,
  "cos", cos,
  "atan", atan,
  "Log", Log,
  "Log10", Log10,
  "Exp", Exp,
  "Sqrt", Sqrt,
  "int", integer,
  "abs", fabs,
  "integer", integer,
  0, 0
};

void init(void) {
  int i;
  Symbol *s;

  for (i = 0; consts[i].name; i++)
    install(consts[i].name, VAR, consts[i].cval);
  
  for (i = 0; builtins[i].name; i++) {
    s = install(builtins[i].name, BLTIN, 0.0);
    s->u.ptr = builtins[i].func;
  }
}
