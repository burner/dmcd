//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T has-passed:yes

//T retval:42

int foo()
{
    return 42;
}

int main()
{
    return test49.foo();
}

