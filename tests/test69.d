//T compiles:no
//T lexer:yes
//T parser:yes
//T semantic:no
//T Disallow implicit conversion between function pointers of different calling convention.


extern(C) void foo(int a)
{
}

int main()
{
	typeof(&foo) ok = &foo;
	void function(int) bad = &foo;
	return 0;
}
