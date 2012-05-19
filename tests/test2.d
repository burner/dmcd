//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:84

//T Tests local variables with simple expressions.

int main()
{
    int a = 42, b = 21;
    int c = 2;
    return a + b * c;
}
