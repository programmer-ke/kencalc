/**
 * Symbol entry table
 */

/* Machine instruction for code generation */
typedef int (*Inst)();   // Machine instruction
#define STOP ((Inst)0)   // sentinel to terminate program

#define NPROG 2000
extern Inst prog[NPROG];
extern Inst *progp;  // next free spot for code generation

typedef struct Symbol {
  char *name;
  short type;  // VAR, BLTIN, UNDEF, NUMBER
  union {
    double val;  // if VAR
    double (*ptr)();  // If BLTIN
  } u;
  struct Symbol *next;  // Link to another symbol in the list
} Symbol;

Symbol *install(const char *s, int t, double d), *lookup(char *s);

typedef union Datum {  // interpreter stack type
  double val;
  Symbol *sym;
} Datum;

void push(Datum d);
Datum pop(void);

void init(void);
void execerror(char *s, char *t);
extern Inst *code(Inst f);
extern double Pow(double, double);

extern void initcode(void);
extern void execute(Inst *p);
extern void constpush(void);
extern void varpush(void);
extern void add(void);
extern void sub(void);
extern void mul(void);
extern void divop(void);
extern void negate(void);
extern void power(void);
extern void assign(void);
extern void bltin(void);
extern void print(void);
extern void popop(void);
extern void eval(void);

