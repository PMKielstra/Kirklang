type value =
| String of string
| Float of float
| Function of expr
| Closure of closure * expr
| Undefined
and vartype =
| Book
| Shelf
| Ghost
and expr = 
| Value of value
| Variable of string
| VariableDef of string * vartype * expr
| Assignment of string * expr
| Brew of expr
| Do of expr
| If of expr * expr * expr
| While of expr * expr
| Intrinsic of (value list -> value) * expr list
| Imperative of expr list
and closure = (string * value) list
;;

let keywords = [
    "book";
    "shelf";
    "ghost";
    "=";
    "brew";
    "do";
    "if";
    "while";
    "fun";
    "imp";
    ";";
    "(";
    ")";
]
;;