//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42


enum {
    A = 42,
    B = A
}

int main()
{
    return B;
}

