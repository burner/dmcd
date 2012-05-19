//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:7


int main()
{
    int i;
    i = 7;
    if (i == 7) {
        goto _out;
    }
    i++;
    _out:
    return i;
}

