//T compiles:no
//T lexer:yes
//T parser:yes
//T semantic:no


void foo()
{
	static assert(false, "test 55 succeeded!");
}
