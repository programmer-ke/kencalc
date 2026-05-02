# kencalc

A calculator language

## Grammar

```
list: (empty)
	  list \n
	  list expr \n
expr: NUMBER
	  expr + expr
	  expr - expr
	  expr * expr
	  expr / expr
	  ( expr )
```
