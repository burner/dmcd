# Distributed multithreaded caching D compiler

dmdc is a Compiler utilizing dex and dalr for lexer and parser generation.
Libhurt is used as std library in combination with the druntime. The Compiler
will be split in two separate programs. 

The compiler daemon which will run until it is advise to quit. This daemon does
the compiler, the work distribution as well as the caching.

The other part is the driver program. It tells the backend what to compile and
gives the user feedback about his compile.
