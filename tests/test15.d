//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:73

//T Simple test of ref.

void change(ref int i, int to)
{
    i = to;
}

int main()
{
    int i = 0;
    change(i, 73);
    return i;
}
