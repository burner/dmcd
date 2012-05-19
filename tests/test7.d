//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:1
//T Tests increment on types smaller than int.

int main()
{
    byte b;
    b++;
    return b;
}

