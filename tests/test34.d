//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:17


struct S
{
	A foo(bar b)
	{
		A a;
		a.i = b;
		return a;
	}
}

struct A
{
	int i;
}

alias int bar;


int main()
{
	S s;
	return s.foo(16).i + 1;
}

