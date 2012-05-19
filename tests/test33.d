//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:25


struct S
{
	static int foo()
	{
		return 21;
	}

	int bar()
	{
		return 4;
	}
}

int main()
{
	S s;
	return S.foo() + s.bar();
}

