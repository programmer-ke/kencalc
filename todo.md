### Phase 1: Internal rewrite to code generation/interpreter
- [x] Define `Inst` type (pointer to function returning `int`) and a fixed-size `prog[]` array.
- [x] Add `initcode()` to reset code generator (progp = prog, stack pointer = stack).
- [x] Add `code(f)` to emit one instruction; add `code2()` and `code3()` macros.
- [x] Add `Datum` union (double or Symbol*) and a stack with `push()` / `pop()`.
- [x] Add `execute(p)` interpreter loop: walk instructions until `STOP`.
- [x] Add `constpush` instruction: pushes a constant number.
- [x] Add `varpush` instruction: pushes a symbol pointer.
- [x] Add `eval` instruction: replaces symbol pointer with its value.
- [x] Add arithmetic instructions: `add`, `sub`, `mul`, `div`, `negate`, `power`.
- [x] Add `assign` instruction: stores value into variable, pushes value back.
- [x] Add `bltin` instruction: calls a built-in function.
- [x] Add `print` instruction: pops and prints a value.
- [x] Add `pop` instruction: discards top of stack.
- [x] Add `STOP` sentinel to terminate `execute()`.
- [x] Change `yylex` to install numbers as anonymous symbols.
- [x] Change grammar actions to emit code instead of computing immediately.
- [x] Change `main()` loop: parse → execute(prog) → initcode() for next line.
- [ ] Test changes (dry run then compile and execute)


### Phase 2: Relational and logical operators
- [ ] Add `gt`, `ge`, `lt`, `le`, `eq`, `ne` instructions.
- [ ] Add `and`, `or`, `not` instructions.
- [ ] Add `%left` / `%right` precedence declarations for relational and logical operators.
- [ ] Add grammar productions for relational and logical operators.

### Phase 3: Control flow
- [ ] Add `ifcode()` instruction: condition → branch to then or else part.
- [ ] Add `whilecode()` instruction: condition → loop body → repeat.
- [ ] Add `STOP`-terminated code sequences for condition, then-body, else-body, and loop body.
- [ ] Add `if` grammar production (without else) that reserves slots and backpatches them.
- [ ] Add `if`–`else` grammar production (reserves three slots: then, else, end).
- [ ] Add `while` grammar production (reserves two slots: body, end).
- [ ] Add `{` `}` compound statement grouping (stmtlist).
- [ ] Add `PRINT` keyword and `print` grammar production.
- [ ] Add `prexpr` instruction to print a numeric value.

### Phase 4: Argument references
- [ ] Add `Frame` structure and a frame stack for function/procedure call state.
- [ ] Add `ARG` token; `yylex` recognizes `$` followed by a number.
- [ ] Add `arg` instruction: pushes an argument value onto the stack.
- [ ] Add `argassign` instruction: assigns to an argument.
- [ ] Add `defnonly()` runtime check to reject `$` outside a definition.
- [ ] Add grammar production for `ARG '=' expr` (assignment to argument).

### Phase 5: Function and procedure definitions
- [ ] Add `FUNCTION` and `PROCEDURE` tokens; add `FUNC` and `PROC` keywords.
- [ ] Add `define(sp)` to store generated code address into symbol table.
- [ ] Add `ret()` helper: pops arguments, restores frame pointer, sets program counter.
- [ ] Add `funcret` instruction: pops return value, calls `ret()`, pushes value back.
- [ ] Add `procret` instruction: calls `ret()` without a return value.
- [ ] Add `return` grammar production (with and without expression).
- [ ] Add `call` instruction: saves frame, executes function/procedure code.
- [ ] Modify `execute()`, `ifcode()`, `whilecode()` to check `returning` flag and exit early.
- [ ] Add grammar productions for `func name() { … }` and `proc name() { … }`.
- [ ] Add `procname` production to accept VAR, FUNCTION, or PROCEDURE as a name.

### Phase 6: Input/output and strings
- [ ] Add `STRING` token; `yylex` recognizes quoted strings with backslash escapes.
- [ ] Add `prstr` instruction: prints a string literal.
- [ ] Add `prlist` grammar production to allow mixing expressions and strings in a `print` statement.
- [ ] Add `varread` instruction: reads a number from input into a variable; pushes 1.0 on success, 0.0 on EOF.
- [ ] Add `READ` token; grammar production `read(VAR)`.
- [ ] Add `moreinput()` to open next command-line argument file (or stdin for `-`).
- [ ] Modify `main()` to accept filename arguments and call `moreinput()` on EOF.
