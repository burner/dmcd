//T compiles:no
//T lexer:yes
//T parser:yes
//T semantic:no


void foo(ref long i)
{
    i = 42;
}

int main()
{
    int i;
    foo(i);
    return i;
}

