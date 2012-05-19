//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:1


enum Foo
{
	Bar,
	Baz
}

int main()
{
	return Foo.Baz;
}

