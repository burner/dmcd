//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:4


template Foo(T)
{
    T bar;
}

int main()
{
    Foo!int.bar = 4;
    return Foo!int.bar;
}

