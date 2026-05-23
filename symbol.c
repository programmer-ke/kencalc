#include <string.h>
#include <stdlib.h>
#include "kencalc.h"
#include "y.tab.h"

static Symbol *symlist = 0;  // symbol table linked list

/**
 * @notice Find s in symbol table
 * @param s The symbol name to search
 * @return A pointer to the symbol if found, otherwise 0
 */
Symbol *lookup(char *s) {
  Symbol *sp;

  for (sp = symlist; sp != (Symbol *) 0; sp = sp->next)
    if (strcmp(sp->name, s) == 0)
      return sp;
  return 0;
}

/**
 * @notice Install symbol s into the symbol table
 * @param s The symbol name
 * @param t The symbol type
 * @param d The symbol value
 * @return A pointer to the inserted symbol
 */
Symbol *install(char *s, int t, double d) {
  Symbol *sp;
  char *emalloc();

  sp = (Symbol *) emalloc(sizeof(Symbol));
  sp->name = emalloc(strlen(s) + 1);  // extra space for null terminator
  strcpy(sp->name, s);
  sp->type = t;
  sp->u.val = d;
  sp->next = symlist; // Set the new symbol at the head of the table
  symlist = sp;
  return sp;
}

/**
 * @notice Allocates memory for a given object
 * @return A pointer to the allocated memory if successful, otherwise 0
 */
char *emalloc(unsigned n) {
  char *p;
  p = malloc(n);
  if (p == 0)
    execerror("out of memory", (char *) 0);
  return p;
}
