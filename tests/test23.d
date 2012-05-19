//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42

//T function pointer
int foo()
{
	return 42;
}

int main()
{
	void* p = &foo;
	auto fn = (cast(int function())p)();
	return fn;
}
