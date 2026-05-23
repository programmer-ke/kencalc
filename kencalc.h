/**
 * Symbol entry table
 */
typedef struct Symbol {
  char *name;
  short type;  // VAR, BLTIN, UNDEF
  union {
    double val;  // if VAR
    double (*ptr)();  // If BLTIN
  } u;
  struct Symbol *next;  // Link to another symbol in the list
} Symbol;

Symbol *install(char *s, int t, double d), *lookup(char *s);
void init(void);
void execerror(char *s, char *t);
