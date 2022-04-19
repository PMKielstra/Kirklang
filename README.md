# Kirklang
Kirklang is a programming language for, and inspired by, Kirkland House.  It is incredibly cursed.

## Basics
All knowledge in Kirkland lives in Hicks House.  There are three kinds of things that exist in Hicks House:
* Books: regular mutable variables.  (Everything in Kirklang is globally scoped, because Kirkland is small enough and the group chat active enough that everyone knows what's going on.)
* Shelves: stacks.  Writing to these variables pushes to the stack; reading from them pops from it.
* Ghosts: variables with mystical abilities to talk to those beyond the realm of the program.  Right now this just means that writing to any ghost writes to standard output and reading from any ghost reads to standard input.  If I want to I might add file I/O later, but I probably won't.

You declare a `book` named `x` as `book x` and similarly for `shelf` and `ghost`.  Hence:
```
ghost g = "Hello, World!\n";
```

Books and shelves can store floating-point numbers or strings.  They can also store procedures, defined with `fun` and executed with `do`:
```
ghost g;
book f = fun (g = "Hello, World!\n");
do f;
```
Shelves can store all different types of values at once.  Kirklang is not strongly typed, because Kirkland has people of all types.

If we can `do` good, we must also expect to be able to `brew` good.  Kirklang uses dynamic evaluation, but closures can be created by replacing `fun` with `brew`.  The following code will print `1.`:
```
ghost g;
book x = 1;
book f = brew (g = x);
x = 2;
do f;
```
If the `brew` were a `fun`, the output would be `2.`.

Control flow is achieved by two constructs: `if` and `while`.  In the case of `if`, `0.` is the only truthy value; in the case of `while`, it is the only falsy one.

Both `if` and `while` receive both their conditions and their bodies (including an else case for `if`) in the form of sub-expressions.  For those who want to do more than one thing inside an `if` statement, the `imp` command is provided.  It takes a sequence of sub-expressions and executes them in order.  Hence, fizz buzz:

```
ghost output;
book n = 25;
book k = 1;

while (sub n k) (
	imp
		(if (mod k 15) (output = "fizzbuzz") (if (mod k 3) (output = "fizz") (if (mod k 5) (output = "buzz") (output = k))))
		(output = "\n")
		(k = add k 1)
);
```

Note the use of `sub`, `add`, and `mod`.  Kirklang has no standard library, but it does have implementation-provided _intrinsics_, all of which come before their arguments.  They are currently:
* `add`, `mul`, and `concat`, which add, multiply, or concatenate all their arguments.  (You can pass them as many as you'd like.)
* `sub` and `div`, which are equivalent to OCaml's `(-.)` and `(/.)`.
* `mod`, which is equivalent to `(mod)` in OCaml except that it first converts its arguments to integers rather than doing float modulo arithmetic.

## The Choosening
Kirkland runs on carefully-managed randomness.  So does Kirklang.  The evaluator takes, not a path to a file, but a path to a folder with possibly dozens of files.  (The file extension is `.kds`.)  First, it looks for a `generic.kds` file.  If it finds none, it picks a random file and executes that.

If, however, there is a `generic.kds` file, the evaluator will first choose a random "week file" from the other `.kds` files in the folder.  Then, any _section markers_ of the form `SECTION secname` in the `generic.kds` file will be replaced with the relevant sections from the week file.  For example, say that the following is our `generic.kds`:
```
ghost out;
out = "It is "

SECTION printweek

out = " week!\n"
```

Then we can write a number of week files and choose any names we like for them as long as we end them with `.kds`.  Say that we have two.  The first is `poleweek.kds`:
```
SECTION printweek
out = "pole"
```
Similarly, we write `change.kds`:
```
SECTION printweek
out = "change"
```

Running the evaluator on the folder with these three files in it will randomly output either `It is change week!` or `It is pole week!`.
## Bug reports
If you're using Kirklang, you have bigger problems.
