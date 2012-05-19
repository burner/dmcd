//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42


int main()
{
    int i = 0;
FOO:
    i++;
    if (i != 42) {
        if (i == 27) {
            i = 27;
        }
        goto FOO;
    }
    return i;
}

